// © Sybl

import Foundation

/// Types that conform to the `ErrorConvertible` protocol can be used to construct an `Error`.
public protocol ErrorConvertible {

  /// Constructs an `Error` from the conforming instance.
  ///
  /// - Throws: When there is an error (ironically) constructing the error.
  ///
  /// - Returns: The `Error`.
  func asError() throws -> Error
}
