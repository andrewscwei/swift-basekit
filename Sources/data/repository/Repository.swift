import Foundation

/// Specifies if debug mode is enabled for `Repository` instances.
public var kRepositoryDebugMode = false

/// A `Repository` provides access to some data (as defined by the associated
/// type `DataType`) that is fetched and aggregated from one or more sources.
///
/// A `Repository` syncs its data stored in memory with the data stored from
/// external sources. Incomplete syncs are discarded when a new sync is
/// requested. Consumers awaiting synced data will always receive the data from
/// the latest sync.
open class Repository<T: Codable & Equatable>: Observable {
  public typealias Observer = RepositoryObserver
  public typealias DataType = T

  /// Specifies if this repository automatically syncs when data is unavailable,
  /// i.e. upon instantiation or `get()`.
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

  /// List of handlers to be invoked when the current running sync job is
  /// complete.
  var syncListeners: [(Result<DataType, Error>) -> Void] = []

  /// Creates a new `Repository` instance.
  ///
  /// - Parameters:
  ///   - queue: The `DispatchQueue` to use for all asynchronous operations,
  ///            defaults to a private concurrent queue with QoS `utility`.
  public init(queue: DispatchQueue = .global(qos: .utility)) {
    self.queue = queue
    lockQueue = .init(label: "BaseKit.Repository.\(Self.self)", qos: .utility)

    if autoSync {
      sync()
    }
  }

  /// Fetches the data in the repository and returns the `Result` containing the
  /// data.
  ///
  /// If data is `nil` and `autoSync` is enabled, the repository will
  /// attempt to sync the data from upstream sources, yielding a `Result` upon
  /// completion.
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
        let error = NSError(domain: "BaseKit.Repository", code: 0, userInfo: [
          NSLocalizedDescriptionKey: "Repository is not synced",
          NSLocalizedFailureErrorKey: "Repository is not synced"
        ])

        completion(.failure(error))
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
  private func syncDownstream(completion: @escaping (Result<DataType, Error>) -> Void) {
    let identifier = generateSyncIdentifier()

    log(.debug, isEnabled: debugMode) { "<\(Self.self)> Syncing downstream (id=\(identifier))..." }

    let workItem = DispatchWorkItem { [weak self] in
      self?.pull { [weak self] result in
        self?.didSyncDownstream(for: identifier, result: result)
      }
    }

    lockQueue.sync {
      self.syncListeners.append(completion)
      self.syncJob = workItem
      self.syncIdentifier = identifier
    }

    queue.async(execute: workItem)
  }

  /// Handler invoked when a downstream sync finishes.
  ///
  /// - Parameters:
  ///   - identifier: The sync identifier.
  ///   - result: The sync result.
  private func didSyncDownstream(for identifier: String, result: Result<DataType, Error>) {
    guard isSyncing(for: identifier) == true else {
      log(.debug, isEnabled: debugMode == true) { "<\(Self.self)> Syncing downstream (id=\(identifier))... SKIP: Operation cancelled, abandoning the current sync progress" }

      return
    }

    switch result {
    case .failure(let error):
      log(.error, isEnabled: debugMode == true) { "<\(Self.self)> Syncing downstream (id=\(identifier))... ERR: \(error)" }
      setCurrent(.notSynced)
    case .success(let data):
      log(.debug, isEnabled: debugMode == true) { "<\(Self.self)> Syncing downstream (id=\(identifier))... OK: \(data)" }
      setCurrent(.synced(data))
    }

    dispatchSyncResult(result)
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
    return lockQueue.sync {
      guard current != value else { return false }

      current = value
      emit(value)

      return true
    }
  }

  /// Generates a new sync job identifier.
  ///
  /// - Returns: The sync identifier.
  func generateSyncIdentifier() -> String { "\(DispatchTime.now().rawValue)" }

  /// Indicates if there exists a running sync job.
  ///
  /// - Returns: `true` if sync is in progress, `false` otherwise.
  func isSyncing() -> Bool { lockQueue.sync { syncJob?.isCancelled == false } }

  /// Indicates if there exists a running sync job for the specified identifier.
  ///
  /// - Parameters:
  ///   - identifier: The sync identifier to check.
  ///
  /// - Returns: `true` if sync is in progress, `false` otherwise.
  func isSyncing(for identifier: String) -> Bool { lockQueue.sync { syncJob?.isCancelled == false && syncIdentifier == identifier } }

  /// Notifies listeners of a sync job result.
  ///
  /// - Parameters:
  ///   - result: The `Result`.
  func dispatchSyncResult(_ result: Result<DataType, Error>) {
    queue.sync(flags: .barrier) {
      lockQueue.sync {
        self.syncListeners.forEach { $0(result) }

        self.syncListeners = []
        self.syncJob = nil
        self.syncIdentifier = nil
      }
    }
  }

  /// Emits the current data to all observers.
  ///
  /// - Parameters:
  ///   - value: The value to emit.
  private func emit(_ value: RepositoryData<DataType>) {
    notifyObservers { observer in
      switch value {
      case .notSynced:
        observer.repositoryDidFailToSyncData(self)
      case .synced(let data):
        observer.repository(self, dataDidChange: data)
      }
    }
  }
}
