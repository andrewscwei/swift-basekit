// © GHOZT

import Foundation

/// Protocol exposing a property for a `ExpressibleByNilLiteral` value that checks if the value is
/// `nil`.
public protocol AnyOptional: ExpressibleByNilLiteral {

  /// Indicates if the value is `nil`.
  var isNil: Bool { get }
}

/// Have `Optional` conform to `AnyOptional` so `ExpressibleByNilLiteral` types not suffixed by `?`
/// can be tested for `nil` value.
extension Optional: AnyOptional {

  public var isNil: Bool { self == nil }
}
