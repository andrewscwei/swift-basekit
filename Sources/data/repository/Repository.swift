import Foundation

/// A `Repository` provides access to asynchronously fetched data of type `T`
/// and stores it in memory.
///
/// The in-memory data syncs with fetched data via a request-collapsing
/// mechanism where the most recent sync satisfies all pending requests.
open class Repository<T: Codable & Equatable & Sendable>: Observable {
  public typealias Observer = RepositoryObserver

  private actor Synchronizer {
    private var task: Task<T, Error>?

    func assign(_ task: Task<T, Error>) {
      self.task?.cancel()
      self.task = task
    }

    func getTask() -> Task<T, Error>? { task }

    func await() async throws -> T {
      guard let task = getTask() else { throw RepositoryError.syncTaskNotFound }

      let result = await task.result

      switch result {
      case .success(let data):
        return data
      case .failure(let error):
        guard case is CancellationError = error else { throw RepositoryError.invalidSync(cause: error) }

        return try await `await`()
      }
    }
  }

  /// Specifies if this repository should automatically sync when data is
  /// unavailable, i.e. upon instantiation or when invoking `get()`.
  open var autoSync: Bool { true }

  let lockQueue: DispatchQueue
  private let synchronizer = Synchronizer()
  private var state: RepositoryState<T> = .idle

  /// Creates a new `Repository` instance.
  public init() {
    lockQueue = .init(label: "BaseKit.Repository.\(Self.self)", qos: .utility)

    if autoSync {
      Task { try? await sync() }
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

  @discardableResult func setState(_ newValue: RepositoryState<T>) -> Bool {
    return lockQueue.sync {
      guard state != newValue else { return false }

      state = newValue

      notifyObservers {
        switch state {
        case .idle:
          $0.repositoryDidFailToSyncData(self)
        case .synced(let data), .notSynced(let data):
          $0.repository(self, dataDidChange: data)
        }
      }

      return true
    }
  }

  func createSyncTask() -> Task<T, Error> {
    return Task {
      throw RepositoryError.badImplementation(reason: "<\(Self.self)> Subclasses must override `createSyncTask()`")
    }
  }
}
