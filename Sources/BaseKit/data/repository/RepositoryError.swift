// © GHOZT

import Foundation

/// A type of `Error` thrown by `Repository` types.
public enum RepositoryError: Error {
  /// Attempting to use the repository before it is synced with its data
  /// sources.
  case notSynced(cause: Error? = nil)

  /// There is an error pulling from data sources.
  case pull(cause: Error? = nil)

  /// There is an error pushing to data sources.
  case push(cause: Error? = nil)

  /// Attempting to use the repository before it is synced with its data
  /// sources.
  public static let notSynced: RepositoryError = .notSynced(cause: nil)

  /// There is an error pulling from data sources.
  public static let pull: RepositoryError = .pull(cause: nil)

  /// There is an error pushing to data sources.
  public static let push: RepositoryError = .push(cause: nil)
}
