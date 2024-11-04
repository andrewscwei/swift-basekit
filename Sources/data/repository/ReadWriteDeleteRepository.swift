/// A `Repository` type whose data can be read, written to, and deleted.
public protocol ReadWriteDeleteRepository: ReadWriteRepository where DataType: ExpressibleByNilLiteral {

}

extension ReadWriteDeleteRepository {

  /// Deletes the current value from the repository, triggering a sync.
  public func delete() async throws {
    do {
      try await set(nil)
    }
    catch {
      throw RepositoryError.invalidDelete(cause: error)
    }
  }
}
