import Foundation

/// Protocol for a read-only `Datasource`.
public protocol ReadOnlyDatasource: Datasource {

  /// Reads the data from the datasource.
  ///
  /// - Returns:The value of the data.
  func read() async throws -> DataType
}
