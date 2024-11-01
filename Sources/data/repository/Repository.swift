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
    private(set) var state: RepositoryState<T> = .initial

    func setState(_ newValue: RepositoryState<T>) {
      state = newValue
    }

    func assignTask(_ newTask: Task<T, Error>) {
      task?.cancel()
      task = newTask
    }

    func yieldTask() async throws -> T {
      guard let task = task else { throw RepositoryError.invalidSync }

      do {
        return try await task.value
      }
      catch is CancellationError {
        return try await yieldTask()
      }
      catch {
        throw RepositoryError.invalidSync(cause: error)
      }
    }
  }

  /// Specifies if this repository should automatically sync when data is
  /// unavailable, i.e. upon instantiation or when invoking `get()`.
  open var autoSync: Bool { true }

  private let synchronizer = Synchronizer()
  private var state: RepositoryState<T> = .initial

  /// Creates a new `Repository` instance.
  public init() {
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
  /// - Parameters:
  ///   - identifier: Optional string identifier for this sync process.
  ///
  /// - Returns: The resulting data.
  @discardableResult
  public func sync(identifier: String = UUID().uuidString) async throws -> T {
    let state = await getState()
    let task = createSyncTask(for: state, identifier: identifier)

    await synchronizer.assignTask(task)

    return try await synchronizer.yieldTask()
  }

  func getState() async -> RepositoryState<T> {
    await synchronizer.state
  }

  func setState(_ state: RepositoryState<T>) async {
    guard await synchronizer.state != state else { return }

    await synchronizer.setState(state)

    notifyObservers {
      switch state {
      case .initial:
        $0.repositoryDidFailToSyncData(self)
      case .synced(let data),
          .notSynced(let data):
        $0.repository(self, dataDidChange: data)
      }
    }
  }

  func createSyncTask(for state: RepositoryState<T>, identifier: String) -> Task<T, Error> {
    return Task {
      fatalError("<\(Self.self)> Subclasses must override `createSyncTask()`")
    }
  }
}
