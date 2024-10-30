import Foundation

/// Specifies if debug mode is enabled for `Repository` instances.
nonisolated(unsafe) public var kRepositoryDebugMode = false

/// A `Repository` provides access to some data (as defined by the associated
/// type `DataType`) that is pulled and aggregated from one or more data sources
/// (of type `DataSource`).
open class Repository<T: Codable & Equatable>: Observable {
  public typealias Observer = RepositoryObserver
  public typealias DataType = T

  /// Specifies if this repository automatically syncs when data is unavailable
  /// upon a `get(completion:)`
  open var autoSync: Bool { true }

  /// Specifies if this repository is in debug mode (generating debug logs).
  open var debugMode: Bool { kRepositoryDebugMode }

  /// The current value of the data.
  private var current: RepositoryData<DataType> = .notSynced

  /// `DispatchQueue` for handling all asynchronous operations.
  let queue: DispatchQueue

  /// Serial `DispatchQueue` for accessing and modifying members synchronously,
  /// ensuring thread- safety.
  let lockQueue: DispatchQueue

  /// Identifier for the current sync job.
  var syncIdentifier: String?

  /// `DispatchWorkItem` for the sync operation.
  var syncJob: DispatchWorkItem?

  /// List of closures to be invoked when the current running sync job is
  /// complete.
  var syncListeners: [(Result<DataType, Error>) -> Void] = []

  /// Creates a new `ReadOnlyRepository` instance.
  ///
  /// - Parameters:
  ///   - queue: The `DispatchQueue` to use for all asynchronous operations,
  ///            defaults to a private concurrent queue with QoS `utility`
  ///            shared between all repositories.
  public init(queue: DispatchQueue = .global(qos: .utility)) {
    self.queue = queue
    lockQueue = .init(label: "BaseKit.Repository.\(Self.self)", qos: .utility)

    if autoSync {
      sync()
    }
  }

  /// Fetches the data in the repository and returns the `Result` containing the
  /// data. If data is `nil` and `autoSync` is enabled, The repository will
  /// attempt to sync the data from upstream data sources and yield a `Result`
  /// upon completion.
  ///
  /// - Parameters:
  ///   - completion: Handler invoked upon completion.
  public func get(completion: @escaping (Result<DataType, Error>) -> Void) {
    switch getCurrent() {
    case .synced(let value):
      completion(.success(value))
    case .notSynced:
      if autoSync {
        log(.debug, isEnabled: debugMode) { "<\(Self.self)> Getting stored value... SKIP: Repository not synced, proceeding to sync"}
        sync(completion: completion)
      }
      else {
        completion(.failure(NSError(domain: "BaseKit.Repository", code: 0, userInfo: [
          NSLocalizedDescriptionKey: "Repository is not synced",
          NSLocalizedFailureErrorKey: "Repository is not synced"
        ])))
      }
    }
  }

  /// Gets the current value synchronously.
  ///
  /// - Returns: The current value.
  func getCurrent() -> RepositoryData<DataType> { lockQueue.sync { current } }

  /// Sets the current value synchronously.
  ///
  /// - Parameters:
  ///   - value: The value to set.
  ///
  /// - Returns: `true` if the value changed, `false` otherwise.
  @discardableResult func setCurrent(_ value: RepositoryData<DataType>) -> Bool {
    guard getCurrent() != value else { return false }

    lockQueue.sync { current = value }
    emit()

    return true
  }

  /// Emits the current value to all observers.
  func emit() {
    let value = getCurrent()

    notifyObservers { observer in
      switch value {
      case .notSynced: observer.repositoryDidFailToSyncData(self)
      case .synced(let value): observer.repository(self, dataDidChange: value)
      }
    }
  }

  /// Pulls data from all data sources, of which the resulting data will
  /// overwrite the current data stored in memory and returned.
  ///
  /// - Parameters:
  ///   - completion: Handler invoked upon completion.
  open func pull(completion: @escaping (Result<DataType, Error>) -> Void = { _ in }) {
    fatalError("<\(Self.self)> Subclass must override `pull(completion:)` without calling `super`.")
  }

  /// Synchronizes data across all data sources. In the case of a
  /// `ReadOnlyRepository`, it is equivalent to a `pull`.
  ///
  /// Only one sync job can run at any given time. Until the running job is
  /// complete, subsequent invocations of this method will not trigger a new
  /// job. Instead, the result of the running job will be passed to the
  /// `completion` block when it finishes.
  ///
  /// - Parameters:
  ///   - completion: Handler invoked upon completion.
  public func sync(completion: @escaping (Result<DataType, Error>) -> Void = { _ in }) {
    syncDownstream(completion: completion)
  }

  /// Synchronizes the data downstream.
  ///
  /// - Parameters:
  ///   - completion: Handler invoked upon completion.
  func syncDownstream(completion: @escaping (Result<DataType, Error>) -> Void) {
    syncListeners.append(completion)

    let identifier = generateSyncIdentifier()

    log(.debug, isEnabled: debugMode) { "<\(Self.self)> Syncing downstream (id=\(identifier))..." }

    guard !isSyncing() else {
      log(.debug, isEnabled: debugMode) { "<\(Self.self)> Syncing downstream (id=\(identifier))... SKIP: Previous sync in progress, ignoring current sync request" }
      return
    }

    let workItem = DispatchWorkItem { [weak self] in
      self?.pull { [weak self] result in
        switch result {
        case .failure(let error): log(.error, isEnabled: self?.debugMode == true) { "<\(Self.self)> Pulling from data sources (id=\(identifier))... ERR: \(error)" }
        case .success(let data): log(.debug, isEnabled: self?.debugMode == true) { "<\(Self.self)> Pulling from data sources (id=\(identifier))... OK: \(data)" }
        }

        guard self?.isSyncing(identifier: identifier) == true else {
          log(.debug, isEnabled: self?.debugMode == true) { "<\(Self.self)> Syncing downstream (id=\(identifier))... SKIP: Operation cancelled, abandoning the current sync progress" }
          return
        }

        self?.didSyncDownstream(identifier: identifier, result: result) { [weak self] result in
          guard self?.isSyncing(identifier: identifier) == true else {
            log(.debug, isEnabled: self?.debugMode == true) { "<\(Self.self)> Syncing downstream (id=\(identifier))... SKIP: Operation cancelled, abandoning the current sync progress" }
            return
          }

          switch result {
          case .failure(let error): log(.error, isEnabled: self?.debugMode == true) { "<\(Self.self)> Syncing downstream (id=\(identifier))... ERR: \(error)" }
          case .success(let data): log(.debug, isEnabled: self?.debugMode == true) { "<\(Self.self)> Syncing downstream (id=\(identifier))... OK: \(data)" }
          }

          self?.dispatchSyncResult(result: result)
        }
      }
    }

    syncJob = workItem
    syncIdentifier = identifier
    queue.async(execute: workItem)
  }

  /// Handler invoked upon the completion of a downstream sync. The `completion`
  /// block must be invoked to complete the sync process.
  ///
  /// - Parameters:
  ///   - identifier: The sync identifier.
  ///   - result: The synced result.
  ///   - completion: Handler invoked upon completion.
  func didSyncDownstream(identifier: String, result: Result<DataType, Error>, completion: @escaping (Result<DataType, Error>) -> Void) {
    switch result {
    case .failure: setCurrent(.notSynced)
    case .success(let data): setCurrent(.synced(data))
    }

    completion(result)
  }

  /// Generates a new sync job identifier.
  ///
  /// - Returns: The sync identifier.
  func generateSyncIdentifier() -> String {
    return "\(DispatchTime.now().rawValue)"
  }

  /// Indicates if there exists a running sync job.
  ///
  /// - Parameters:
  ///   - identifier: Specify an identifier to check for a specific sync job. If
  ///                 unspecified, the current job will be checked.
  ///
  /// - Returns: `true` if sync is in progress, `false` otherwise.
  func isSyncing(identifier: String? = nil) -> Bool {
    guard let syncJob = syncJob else { return false }

    if let identifier = identifier {
      guard syncIdentifier == identifier else { return false }
      return !syncJob.isCancelled
    }
    else {
      return !syncJob.isCancelled
    }
  }

  /// Notifies listeners of a sync job result.
  ///
  /// - Parameters:
  ///   - result: The `Result`.
  func dispatchSyncResult(result: Result<DataType, Error>) {
    queue.sync(flags: .barrier) {
      for listener in self.syncListeners {
        listener(result)
      }

      self.syncListeners = []
      self.syncJob = nil
      self.syncIdentifier = nil
    }
  }
}
