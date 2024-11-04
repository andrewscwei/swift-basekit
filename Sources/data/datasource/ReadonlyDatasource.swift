/// Protocol for a readonly `Datasource`.
public protocol ReadonlyDatasource: Datasource {

  /// Reads the data from the datasource.
  ///
  /// - Returns:The value of the data.
  /// - Throws: When reading fails.
  func read() async throws -> DataType
}
