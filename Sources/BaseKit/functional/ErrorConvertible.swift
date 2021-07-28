// © Sybl

import Foundation

/// Types that conform to the `ErrorConvertible` protocol can be used to construct an `Error`.
public protocol ErrorConvertible {

  /// Returns an `Error` from the conforming instance.
  ///
  /// - Throws: When there is an error constructing the error (the irony).
  ///
  /// - Returns: The `Error`.
  func asError() throws -> Error
}
