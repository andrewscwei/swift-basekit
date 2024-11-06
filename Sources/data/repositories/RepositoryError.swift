/// A type of `Error` thrown by `Repository` types.
public enum RepositoryError: Error {

  /// An error indicating data synchronization failure.
  ///
  /// - Parameters:
  ///   - cause: Optional causal `Error`.
  case invalidSync(cause: Error?)

  /// An error indicating data-read failure.
  ///
  /// - Parameters:
  ///   - cause: Optional causal `Error`.
  case invalidRead(cause: Error?)

  /// An error indicating data-write failure.
  ///
  /// - Parameters:
  ///   - cause: Optional causal `Error`.
  case invalidWrite(cause: Error?)

  /// An error indicating data-deletion failure.
  ///
  /// - Parameters:
  ///   - cause: Optional causal `Error`.
  case invalidDelete(cause: Error?)

  /// An error indicating data synchronization failure.
  public static let invalidSync: RepositoryError = .invalidSync(cause: nil)

  /// An error indicating data-read failure.
  public static let invalidRead: RepositoryError = .invalidRead(cause: nil)

  /// An error indicating data-write failure.
  public static let invalidWrite: RepositoryError = .invalidWrite(cause: nil)

  /// An error indicating data-deletion failure.
  public static let invalidDelete: RepositoryError = .invalidDelete(cause: nil)
}
