/// Protocol for a read/write/delete `Datasource`.
public protocol ReadWriteDeleteDatasource: ReadWriteDatasource where DataType: ExpressibleByNilLiteral {

  /// Deletes the existing data from the datasource.
  mutating func delete() async throws
}
