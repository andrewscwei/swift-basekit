import Foundation

/// An abstract class for a read/write/delete `Repository`.
open class ReadWriteDeleteRepository<T: Codable & Equatable>: ReadWriteRepository<T?> {
  /// Deletes the current value from the repository and triggers a sync if
  /// `autoSync` is `true`.
  public func delete() async throws {
    try await set(nil)
  }
}
