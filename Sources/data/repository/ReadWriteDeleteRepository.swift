/// A `Repository` type whose data can be read, written, and deleted.
///
/// The associated `DataType` must be declared optional. `nil` indicates an
/// absence of data from the data source(s), i.e. when the data has been
/// deleted.
public protocol ReadWriteDeleteRepository: ReadWriteRepository where DataType: ExpressibleByNilLiteral {

}

extension ReadWriteDeleteRepository {

  /// Deletes the current value from the repository and synchronizes with result
  /// with data source(s).
  ///
  /// - Throws: If synchronization fails.
  public func delete() async throws {
    do {
      try await set(nil)
    }
    catch {
      throw RepositoryError.invalidDelete(cause: error)
    }
  }
}
