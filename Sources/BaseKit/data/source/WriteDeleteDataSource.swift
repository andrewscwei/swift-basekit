import Foundation

/// Protocol for a write/delete `DataSource`.
public protocol WriteDeleteDataSource: WriteOnlyDataSource {
  /// Deletes the existing data from the data source and passes a `Result` to a
  /// callback. The `Result` should be a `.failure` if there is no data to
  /// delete.
  ///
  /// - Parameters:
  ///   - completion: Handler invoked with the `Result` upon completion.
  func delete(completion: @escaping (Result<Void, Error>) -> Void)
}
