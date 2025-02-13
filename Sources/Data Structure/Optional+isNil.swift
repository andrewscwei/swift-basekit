/// Have `Optional` conform to `AnyOptional` so `ExpressibleByNilLiteral` types
/// not suffixed by `?` can be tested for `nil` value.
extension Optional: AnyOptional {
  public var isNil: Bool { self == nil }
}
