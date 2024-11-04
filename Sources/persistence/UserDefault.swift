/// Property wrapper for setting/getting a value of type `T` to/from
/// `UserDefaults`. Optional values are supported.
@propertyWrapper
public struct UserDefault<T: Codable> {
  private let key: String

  public let defaultValue: T

  public var projectedValue: UserDefault<T> { self }

  public var wrappedValue: T {
    get {
      return try! UserDefaultsUtil.get(key, default: defaultValue)
    }

    set {
      try! UserDefaultsUtil.set(key, value: newValue)
    }
  }

  public init(_ key: String, default defaultValue: T) {
    self.key = key
    self.defaultValue = defaultValue
  }
}

extension UserDefault where T: ExpressibleByNilLiteral {
  public init(_ key: String) {
    self.init(key, default: nil)
  }
}
