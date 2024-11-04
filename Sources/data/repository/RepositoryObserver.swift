/// A type conforming to the `RepositoryObserver` protocol is notified whenever
/// the data in the observed `Repository` changes.
public protocol RepositoryObserver {

  /// Handler invoked when the data of the observed `Repository` changes.
  ///
  /// - Parameters:
  ///   - repository: The observed `Repository`.
  ///   - data: The changed data.
  func repository<T: Repository>(_ repository: T, dataDidChange data: T.DataType)

  /// Handler invoked when the data of the observed `Repository` fails to sync.
  ///
  /// - Parameters:
  ///   - repository: The observed `Repository`.
  func repositoryDidFailToSyncData<T: Repository>(_ repository: T)
}
