import Foundation

/// Provides access to fetched data of type `T`, stored in memory.
///
/// Syncs in-memory data with fetched data using request-collapsing. The latest
/// sync satisfies all pending requests.
public protocol Repository: Observable, Sendable where Observer == RepositoryObserver {
  associatedtype DataType: RepositoryData

  var synchronizer: RepositorySynchronizer<DataType> { get }

  func createSyncTask(for state: RepositoryState<DataType>, identifier: String) -> Task<DataType, any Error>
}

extension Repository {

  /// Synchronizes data across datasource(s).
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
  public func sync(identifier: String = UUID().uuidString) async throws -> DataType {
    let state = await getState()
    let task = createSyncTask(for: state, identifier: identifier)

    await synchronizer.assignTask(task)

    return try await synchronizer.yieldTask()
  }

  func getState() async -> RepositoryState<DataType> {
    await synchronizer.state
  }

  func setState(_ state: RepositoryState<DataType>) async {
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
}
