import Foundation

/// Provides access to data of type `T` retrieved from data source(s). Data is
/// stored in memory and updates whenever synchronization happens.
///
/// In-memory data is synchronized with fetched data via request-collapsing—the
/// latest sync satisfies all pending requests.
///
/// Repositories are observable by explicitly adding observers conforming to
/// `RepositoryObserver` to it.
///
/// `associatedtype`:
///   - `DataType`: Type of the repository data.
public protocol Repository where Self: Actor {
  associatedtype DataType: RepositoryData

  /// An actor ensuring thread-safety during data synchronization and state
  /// changes.
  var synchronizer: RepositorySynchronizer<DataType> { get }

  /// Creates the synchronization task.
  ///
  /// - Parameters:
  ///   - state: The current state of the repository.
  ///   - identifier: A custom unique identifier for the task, useful in debug.
  /// - Returns: The task.
  func createSyncTask(for state: RepositoryState<DataType>, identifier: String) -> Task<DataType, any Error>
}

extension Repository {

  /// Synchronizes data across data source(s).
  ///
  /// Only one sync task can run at any given time. Until the running task is
  /// complete, subsequent invocations of this method will not initiate a new
  /// task. The callers of previous syncs will receive the result of the last
  /// sync.
  ///
  /// - Parameters:
  ///   - identifier: Optional unique identifier for this sync task.
  /// - Returns: The resulting data.
  /// - Throws: If sync fails.
  @discardableResult
  public func sync(identifier: String = UUID().uuidString) async throws -> DataType {
    let task = createSyncTask(for: await getState(), identifier: identifier)

    await synchronizer.assignTask(task)

    do {
      let newData = try await synchronizer.yieldTask()

      if case .synced(let data) = await getState(), data == newData {

      }
      else {
        await setState(.synced(newData))
        await synchronizer.notifyObservers { $0.repository(self, didSyncWithData: newData) }
      }

      return newData
    }
    catch {
      switch await getState() {
      case .synced(let data):
        await setState(.notSynced(data))
      default:
        break
      }

      await synchronizer.notifyObservers { $0.repository(self, didFailToSyncWithError: error) }

      throw error
    }
  }

  /// Registers a weakly referenced observer.
  ///
  /// - Parameters:
  ///   - observer: The observer to add.
  public func addObserver(_ observer: RepositoryObserver) {
    Task {
      await synchronizer.addObserver(observer)
    }
  }

  /// Unregisters an existing observer.
  ///
  /// - Parameters:
  ///   - observer: The observer to remove.
  public func removeObserver(_ observer: any RepositoryObserver) {
    Task {
      await synchronizer.removeObserver(observer)
    }
  }

  /// Gets the current state of the repository.
  ///
  /// - Returns: The current state.
  public func getState() async -> RepositoryState<DataType> {
    await synchronizer.state
  }


  /// Sets the current state of the repository.
  ///
  /// - Parameters:
  ///   -  state: The state to set.
  public func setState(_ state: RepositoryState<DataType>) async {
    guard await synchronizer.state != state else { return }

    await synchronizer.setState(state)
  }
}
