import Foundation

/// An abstract class for a read/write/delete `Repository`.
open class ReadWriteDeleteRepository<T: Syncable>: ReadWriteRepository<T?> {
  /// Deletes the current value from the repository and triggers a sync if
  /// `autoSync` is `true`.
  public func delete() async throws {
    do {
      try await set(nil)
    }
    catch {
      throw RepositoryError.invalidDelete(cause: error)
    }
  }
}
