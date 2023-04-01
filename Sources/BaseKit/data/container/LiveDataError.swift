// © GHOZT

import Foundation

/// A type of `Error` thrown by `LiveData` types.
public enum LiveDataError: Error {
  /// Attempting to modify the wrapped value of an immutable `LiveData` type.
  case immutable(cause: Error? = nil)
}
