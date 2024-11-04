import Foundation

/// Protocol for a read/write/delete `Datasource`.
public protocol ReadWriteDeleteDatasource: Datasource {
  /// Reads the data from the datasource.
  ///
  /// - Returns: The resulting data. Note that the data can be `nil`, such as
  ///            when it is deleted or simply never existed.
  func read() async throws -> DataType?

  /// Writes data to the datasource.
  ///
  /// - Parameters:
  ///   - data: The data to write.
  ///
  /// - Returns: The written data.
  mutating func write(_ data: DataType?) async throws -> DataType?

  /// Deletes the existing data from the datasource.
  mutating func delete() async throws
}
