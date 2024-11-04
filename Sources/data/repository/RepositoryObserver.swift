/// A type conforming to the `RepositoryObserver` protocol gets notified
/// whenever the data in the target `Repository` changes.
public protocol RepositoryObserver {

  /// Handler invoked when the data of the observed `Repository` is synced
  /// and/or changed.
  ///
  /// - Parameters:
  ///   - repository: The observed `Repository`.
  ///   - data: The new data.
  func repository<T: Repository>(_ repository: T, dataDidChange data: T.DataType)

  /// Handler invoked when the data of the observed `Repository` fails to sync.
  ///
  /// - Parameters:
  ///   - repository: The observed `Repository`.
  func repositoryDidFailToSyncData<T: Repository>(_ repository: T)
}
