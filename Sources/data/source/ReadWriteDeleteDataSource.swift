import Foundation

/// Protocol for a read/write/delete `DataSource`.
public protocol ReadWriteDeleteDataSource: WriteDeleteDataSource {
  /// Reads the value of the data from the data source.
  ///
  /// - Returns: The value of the data. Note that the value can be `nil`
  ///            indicating the absence of a value (i.e. deleted).
  @discardableResult func read() async throws -> DataType?
}

