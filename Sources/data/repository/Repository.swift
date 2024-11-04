import Foundation

/// A `Repository` provides access to asynchronously fetched data of type `T`
/// and stores it in memory.
///
/// The in-memory data syncs with fetched data via a request-collapsing
/// mechanism where the most recent sync satisfies all pending requests.
open class Repository<T: Syncable>: Observable {
  public typealias Observer = RepositoryObserver

  /// Specifies if this repository should automatically sync when data is
  /// unavailable, i.e. upon instantiation or when invoking `get()`.
  open var autoSync: Bool { true }

  private let synchronizer = RepositorySynchronizer<T>()

  /// Creates a new `Repository` instance.
  public init() {
    if autoSync {
      Task {
        try? await sync()
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
    fatalError("<\(Self.self)> Subclasses must override `createSyncTask(for:identifier:)`")
  }
}
