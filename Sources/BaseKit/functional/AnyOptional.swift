// © Sybl

import Foundation

/// Convenience protocol to indicate that the conforming object is expressible by a `nil` literal but not necessarily marked with `?`.
public protocol AnyOptional {
  var isNil: Bool { get }
}

/// This extension is used when it is necessary to determine if an optional value not marked with `?` is `nil`. An example of such usage is in property wrappers that handle generic type `T` with `ExpressibleByNilLiteral` as its constraint.
extension Optional: AnyOptional {
  public var isNil: Bool { self == nil }
}
