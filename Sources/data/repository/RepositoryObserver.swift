import Foundation

/// A type conforming to the `RepositoryObserver` protocol gets notified
/// whenever the data in the target `Repository` changes.
public protocol RepositoryObserver: AnyObject {

  /// Handler invoked when the data of the observed `Repository` is synced
  /// and/or changed.
  ///
  /// - Parameters:
  ///   - repository: The observed `Repository`.
  ///   - data: The new data.
  func repository<T: Syncable>(_ repository: Repository<T>, dataDidChange data: T)

  /// Handler invoked when the data of the observed `Repository` fails to sync.
  ///
  /// - Parameters:
  ///   - repository: The observed `Repository`.
  func repositoryDidFailToSyncData<T: Syncable>(_ repository: Repository<T>)
}
