/// A type of `Error` thrown by `Repository` types.
public enum RepositoryError: Error {

  /// An error occurred during data synchronization.
  ///
  /// - Parameters:
  ///   - cause: Optional causal `Error`.
  case invalidSync(cause: Error?)

  /// An error occurred while reading from datasource(s).
  ///
  /// - Parameters:
  ///   - cause: Optional causal `Error`.
  case invalidRead(cause: Error?)

  /// An error occurred while writing to datasource(s).
  ///
  /// - Parameters:
  ///   - cause: Optional causal `Error`.
  case invalidWrite(cause: Error?)

  /// An error occurred while deleting from datasource(s).
  ///
  /// - Parameters:
  ///   - cause: Optional causal `Error`.
  case invalidDelete(cause: Error?)

  /// An error occurred during data synchronization.
  public static let invalidSync: RepositoryError = .invalidSync(cause: nil)

  /// An error occurred while reading from datasource(s).
  public static let invalidRead: RepositoryError = .invalidRead(cause: nil)

  /// An error occurred while writing to datasource(s).
  public static let invalidWrite: RepositoryError = .invalidWrite(cause: nil)

  /// An error occurred while deleting from datasource(s).
  public static let invalidDelete: RepositoryError = .invalidDelete(cause: nil)
}
