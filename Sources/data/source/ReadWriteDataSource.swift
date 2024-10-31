import Foundation

/// Protocol for a read/write `DataSource`.
public protocol ReadWriteDataSource: ReadOnlyDataSource {
  /// Writes data to the data source.
  ///
  /// - Returns: The written data.
  mutating func write(_ value: DataType) async throws -> DataType
}
