/// An `ExpressibleByNilLiteral` value conforming to the `AnyOptional` protocol
/// implements a property that indicates if it is equal to `nil`.
public protocol AnyOptional: ExpressibleByNilLiteral {

  /// Indicates if the value is `nil`.
  var isNil: Bool { get }
}
