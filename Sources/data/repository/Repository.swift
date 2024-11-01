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

    func assignTask(_ task: Task<T, Error>) {
      self.task?.cancel()
      self.task = task
    }

    func getTask() -> Task<T, Error>? { task }

    func awaitTask() async throws -> T {
      guard let task = getTask() else { throw RepositoryError.invalidSync }

      do {
        return try await task.value
      }
      catch is CancellationError {
        return try await awaitTask()
      }
      catch {
        throw RepositoryError.invalidSync(cause: error)
      }
    }
  }

  /// Specifies if this repository should automatically sync when data is
  /// unavailable, i.e. upon instantiation or when invoking `get()`.
  open var autoSync: Bool { true }

  let lockQueue: DispatchQueue
  private let synchronizer = Synchronizer()
  private var state: RepositoryState<T> = .initial

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
    await synchronizer.assignTask(createSyncTask())

    return try await synchronizer.awaitTask()
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
        case .initial:
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
      fatalError("<\(Self.self)> Subclasses must override `createSyncTask()`")
    }
  }
}
