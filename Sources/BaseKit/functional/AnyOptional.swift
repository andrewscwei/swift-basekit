// © Sybl

import Foundation

/// Protocol for checking if the value of an `Optional` type is `nil`.
public protocol AnyOptional: ExpressibleByNilLiteral {

  /// Indicates if the value is `nil`.
  var isNil: Bool { get }
}

/// Have `Optional` conform to `AnyOptional` so `ExpressibleByNilLiteral` types not suffixed by `?` can be tested for
/// `nil` value.
extension Optional: AnyOptional {

  public var isNil: Bool { self == nil }
}
