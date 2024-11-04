import Foundation

/// An `ExpressibleByNilLiteral` value conforming to the `AnyOptional` protocol
/// implements a property that indicates if it is equal to `nil`.
public protocol AnyOptional: ExpressibleByNilLiteral {

  /// Indicates if the value is `nil`.
  var isNil: Bool { get }
}

/// Have `Optional` conform to `AnyOptional` so `ExpressibleByNilLiteral` types
/// not suffixed by `?` can be tested for `nil` value.
extension Optional: AnyOptional {
  public var isNil: Bool { self == nil }
}
