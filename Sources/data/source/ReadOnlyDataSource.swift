import Foundation

/// Protocol for a read-only `DataSource`.
public protocol ReadOnlyDataSource: DataSource {
  /// Reads the data from the data source.
  ///
  /// - Returns:The value of the data.
  func read() async throws -> DataType
}
