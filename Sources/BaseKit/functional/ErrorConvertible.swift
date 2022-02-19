// © GHOZT

import Foundation

/// A type conforming to the `ErrorConvertible` protocol can construct an `Error` from itself.
public protocol ErrorConvertible {

  /// Constructs an `Error`.
  ///
  /// - Throws: When there is an error (ironically) constructing the error.
  ///
  /// - Returns: The `Error`.
  func asError() throws -> Error
}
