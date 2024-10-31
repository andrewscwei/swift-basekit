import Foundation

/// Specifies if debug mode is enabled for `Repository` instances.
public var kRepositoryDebugMode = false

/// A `Repository` provides access to asynchronously fetched data of type `T`
/// and stores it in memory.
///
/// The in-memory data syncs with fetched data via a request-collapsing
/// mechanism where the most recent sync satisfies all pending requests.
open class Repository<T: Codable & Equatable>: Observable {
  public typealias Observer = RepositoryObserver

  private actor Synchronizer {
    private var task: Task<T, Error>?

    func assign(_ task: Task<T, Error>) {
      self.task?.cancel()
      self.task = task
    }

    func getTask() -> Task<T, Error>? { task }

    func await() async throws -> T {
      guard let task = getTask() else { throw CancellationError() }

      let result = await task.result

      switch result {
      case .success(let data):
        return data
      case .failure(let error):
        guard case is CancellationError = error else { throw error }

        return try await `await`()
      }
    }
  }

  /// Specifies if this repository is in debug mode (generating debug logs).
  open var debugMode: Bool { kRepositoryDebugMode }

  /// Specifies if this repository should automatically sync when data is
  /// unavailable, i.e. upon instantiation or when invoking `get()`.
  open var autoSync: Bool { true }

  let lockQueue: DispatchQueue
  private let synchronizer = Synchronizer()
  private var state: RepositoryState<T> = .notSynced

  /// Creates a new `Repository` instance.
  public init() {
    lockQueue = .init(label: "BaseKit.Repository.\(Self.self)", qos: .utility)

    if autoSync {
      Task { try? await sync() }
    }
  }

  /// Pulls the data downstream.
  ///
  /// This method implements how data is fetched from the data source(s).
  ///
  /// - Returns: The resulting data.
  open func pull() async throws -> T {
    fatalError("<\(Self.self)> Subclass must override `pull()` without calling `super`.")
  }

  /// Returns the data in memory.
  ///
  /// If data has not been synced and `autoSync` is enabled, a sync will be
  /// attempted and the synced data returned upon completion.
  ///
  /// - Throws: If data is not available.
  public func get() async throws -> T {
    log(.debug, isEnabled: debugMode) { "<\(Self.self)> Getting data..."}

    switch getState() {
    case .synced(let data):
      log(.debug, isEnabled: debugMode) { "<\(Self.self)> Getting data... OK: \(data)"}

      return data
    case .notSynced:
      guard autoSync else {
        let err = error("Repository is not synced", domain: "BaseKit.Repository")

        log(.error, isEnabled: debugMode) { "<\(Self.self)> Getting data... ERR: \(err)"}

        throw err
      }

      log(.debug, isEnabled: debugMode) { "<\(Self.self)> Getting data... repository not synced, proceeding to sync"}

      do {
        let data = try await sync()

        log(.debug, isEnabled: debugMode) { "<\(Self.self)> Getting data... OK: \(data)"}

        return data
      }
      catch {
        log(.error, isEnabled: debugMode) { "<\(Self.self)> Getting data... ERR: \(error)"}

        throw error
      }
    }
  }

  /// Synchronizes data across all data sources.
  ///
  /// Only one sync task can run at any given time. Until the running task is
  /// complete, subsequent invocations of this method will not trigger a new
  /// task. The callers of previous syncs will receive the result of the last
  /// sync.
  ///
  /// - Returns: The resulting data.
  @discardableResult public func sync() async throws -> T {
    await synchronizer.assign(createSyncTask())

    return try await synchronizer.await()
  }

  func getState() -> RepositoryState<T> {
    lockQueue.sync { state }
  }

  func setState(_ newValue: RepositoryState<T>) -> Bool {
    return lockQueue.sync {
      guard state != newValue else { return false }

      state = newValue

      notifyObservers {
        switch state {
        case .notSynced:
          $0.repositoryDidFailToSyncData(self)
        case .synced(let data):
          $0.repository(self, dataDidChange: data)
        }
      }

      return true
    }
  }

  func createSyncTask() -> Task<T, Error> {
    return Task {
      log(.debug, isEnabled: debugMode) { "<\(Self.self)> Syncing downstream..."}

      let result = await Task { try await pull() }.result

      do {
        try Task.checkCancellation()
      }
      catch {
        log(.debug, isEnabled: debugMode) { "<\(Self.self)> Syncing downstream... CANCEL: Current sync has been overridden"}

        throw error
      }

      switch result {
      case .success(let data):
        let isDirty = setState(.synced(data))

        if isDirty {
          log(.debug, isEnabled: debugMode) { "<\(Self.self)> Syncing downstream... OK: \(data)" }
        }
        else {
          log(.debug, isEnabled: debugMode) { "<\(Self.self)> Syncing downstream... SKIP: No changes" }
        }

        return data
      case .failure(let error):
        let _ = setState(.notSynced)

        log(.error, isEnabled: debugMode) { "<\(Self.self)> Syncing downstream... ERR: \(error)"}

        throw error
      }
    }
  }
}
