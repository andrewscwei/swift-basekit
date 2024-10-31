import Foundation

/// Protocol for a read/write/delete `DataSource`.
public protocol ReadWriteDeleteDataSource: DataSource {
  /// Reads the data from the data source.
  ///
  /// - Returns: The resulting data. Note that the data can be `nil`, such as
  ///            when it is deleted or simply never existed.
  func read() async throws -> DataType?

  /// Writes data to the data source.
  ///
  /// - Returns: The written data.
  mutating func write(_ value: DataType?) async throws -> DataType?

  /// Deletes the existing data from the data source.
  mutating func delete() async throws
}
