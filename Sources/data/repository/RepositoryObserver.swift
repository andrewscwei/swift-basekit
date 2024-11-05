/// A type conforming to the `RepositoryObserver` protocol is notified whenever
/// the data in the observed `Repository` changes.
public protocol RepositoryObserver: AnyObject {

  /// Handler invoked when the data of the observed `Repository` successfully
  /// syncs with updated data.
  ///
  /// - Parameters:
  ///   - repository: The observed `Repository`.
  ///   - data: The updated data.
  func repository<T: Repository>(_ repository: T, didSyncWithData data: T.DataType)

  /// Handler invoked when the data of the observed `Repository` fails to sync.
  ///
  /// - Parameters:
  ///   - repository: The observed `Repository`.
  ///   - error: The error.
  func repository<T: Repository>(_ repository: T, didFailToSyncWithError error: Error)
}

extension RepositoryObserver {
  func repository<T: Repository>(_ repository: T, didFailToSyncWithError error: Error) {}
}
