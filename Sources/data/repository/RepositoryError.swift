/// A type of `Error` thrown by `Repository` types.
public enum RepositoryError: Error {
  /// The repository is not implemented according to specs.
  case badImplementation(reason: String)

  /// Sync task is `nil`.
  case syncTaskNotFound

  /// An error occurred during sync.
  case badSync(cause: Error)

  /// There is an error reading from the data source.
  case invalidRead(cause: Error)

  /// There is an error writing to the data source.
  case invalidWrite(cause: Error)

  /// There is an error deleting from the data source.
  case invalidateDelete(cause: Error)
}