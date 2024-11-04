/// Protocol for a read/write/delete `Datasource`.
///
/// The associated `DataType` must be declared optional. `nil` indicates an
/// absence of data from the datasource, i.e. when the data has been deleted.
public protocol ReadWriteDeleteDatasource: ReadWriteDatasource where DataType: ExpressibleByNilLiteral {

  /// Deletes the existing data from the datasource.
  ///
  /// - Throws: When deleting fails.
  mutating func delete() async throws
}
