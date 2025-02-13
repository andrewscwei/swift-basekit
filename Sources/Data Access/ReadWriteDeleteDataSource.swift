/// Protocol for a read/write/delete `DataSource`.
///
/// The associated `DataType` must be declared optional. `nil` indicates an
/// absence of data from the data source, i.e. when the data has been deleted.
public protocol ReadWriteDeleteDataSource: ReadWriteDataSource where DataType: ExpressibleByNilLiteral {

  /// Deletes the existing data from the data source.
  ///
  /// - Throws: When deleting fails.
  mutating func delete() async throws
}
