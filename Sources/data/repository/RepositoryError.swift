/// A type of `Error` thrown by `Repository` types.
public enum RepositoryError: Error {
  /// An error occurred during sync.
  case invalidSync(cause: Error?)

  /// There is an error reading from the datasource.
  case invalidRead(cause: Error)

  /// There is an error writing to the datasource.
  case invalidWrite(cause: Error)

  /// There is an error deleting from the datasource.
  case invalidDelete(cause: Error)

  public static let invalidSync: RepositoryError = .invalidSync(cause: nil)
}
