import Foundation

/// Protocol for a read/write `Datasource`.
public protocol ReadWriteDatasource: ReadonlyDatasource {

  /// Writes data to the datasource.
  ///
  /// - Parameters:
  ///   - data: The data to write.
  ///
  /// - Returns: The written data.
  mutating func write(_ data: DataType) async throws -> DataType
}
