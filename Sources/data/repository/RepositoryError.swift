/// A type of `Error` thrown by `Repository` types.
public enum RepositoryError: Error {
  /// An error occurred during sync.
  case invalidSync(cause: Error?)

  /// There is an error reading from the data source.
  case invalidRead(cause: Error)

  /// There is an error writing to the data source.
  case invalidWrite(cause: Error)

  /// There is an error deleting from the data source.
  case invalidateDelete(cause: Error)

  public static let invalidSync: RepositoryError = .invalidSync(cause: nil)
}
