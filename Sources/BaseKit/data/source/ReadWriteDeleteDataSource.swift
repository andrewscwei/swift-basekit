// © GHOZT

import Foundation

/// Protocol for a read/write/delete `DataSource`.
public protocol ReadWriteDeleteDataSource: WriteDeleteDataSource {
  /// Asynchronously reads from the data source and passes the read value
  /// wrapped in a `Result` to a callback.
  ///
  /// - Parameters:
  ///   - completion: Handler invoked with the `Result` upon completion.
  func read(completion: @escaping (Result<DataType?, Error>) -> Void)
}

