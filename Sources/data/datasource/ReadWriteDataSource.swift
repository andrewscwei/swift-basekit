/// Protocol for a read/write `DataSource`.
public protocol ReadWriteDataSource: ReadOnlyDataSource {

  /// Writes data to the data source.
  ///
  /// - Parameters:
  ///   - data: The data to write.
  /// - Returns: The written data.
  /// - Throws: When writing fails.
  mutating func write(_ data: DataType) async throws -> DataType
}
