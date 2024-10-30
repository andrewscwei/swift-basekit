import Foundation

/// Protocol for a write-only `DataSource`.
public protocol WriteOnlyDataSource: DataSource {
  /// Asynchronously writes to the data source.
  ///
  /// - Returns: The value of the data that was written.
  @discardableResult func write(_ value: DataType) async throws -> DataType
}
