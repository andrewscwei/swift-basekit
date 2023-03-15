// © GHOZT

import Foundation

/// A type of `Error` thrown by `DataSource` types.
public enum DataSourceError: Error {
  /// The value stored in the data source is unexpectedly `nil`.
  case unexpectedNilValue(cause: Error? = nil)

  /// There is an error reading from the data source.
  case read(cause: Error? = nil)

  /// There is an error writing to the data source.
  case write(cause: Error? = nil)

  /// There is an error deleting from the data source.
  case delete(cause: Error? = nil)

  /// The value stored in the data source is unexpectedly `nil`.
  public static let unexpectedNilValue: DataSourceError = .unexpectedNilValue(cause: nil)

  /// There is an error reading from the data source.
  public static let read: DataSourceError = .read(cause: nil)

  /// There is an error writing to the data source.
  public static let write: DataSourceError = .write(cause: nil)

  /// There is an error deleting from the data source.
  public static let delete: DataSourceError = .delete(cause: nil)
}
