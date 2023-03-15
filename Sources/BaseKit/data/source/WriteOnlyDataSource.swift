// © GHOZT

import Foundation

/// Protocol for a write-only `DataSource`.
public protocol WriteOnlyDataSource: DataSource {
  /// Asynchronously writes to the data source and passes the written value
  /// wrapped in a `Result` to a callback.
  ///
  /// - Parameters:
  ///   - value: The value to write to the data source.
  ///   - completion: Handler invoked with the `Result` upon completion.
  func write(_ value: DataType, completion: @escaping (Result<DataType, Error>) -> Void)
}
