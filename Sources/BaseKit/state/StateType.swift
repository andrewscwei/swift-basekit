// © GHOZT

/// `StateMachine` state type.
///
/// This struct is meant to be extended to define application-specific state
/// types. Use the `factory()` method to generate unique `StateType` values at
/// runtime. Note that when applied to static constants, their order of
/// declaration does not guarantee the order of `StateType` generation:
///
/// ```
/// extension StateType {
///   // The raw values below could be 1 (001), 2 (010), or 4 (100), in any order.
///   static let customType1 = StateType.factory()
///   static let customType2 = StateType.factory()
///   static let customType3 = StateType.factory()
/// }
/// ```
public struct StateType: OptionSet {

  public let rawValue: Int

  /// Static counter for `factory()` method.
  private static var factoryCount = 0

  /// An empty `StateType`.
  public static let none: StateType = []

  /// A `StateType` covering all possible `StateType` values.
  public static let all: StateType = StateType(rawValue: Int.max)

  public init(rawValue: Int) {
    self.rawValue = rawValue
  }

  /// Generates a runtime unique `StateType`.
  ///
  /// - Returns: A unique `StateType`.
  public static func factory() -> StateType {
    let stateType = StateType(rawValue: 1 << factoryCount)
    factoryCount += 1
    return stateType
  }

  /// Verifies if this `StateType` set includes the specified `StateType`
  /// values.
  ///
  /// - Parameters:
  ///   - types: `StateType` values.
  ///
  /// - Returns: `true` if any one of the provided `StateType` values is
  ///             included, `false` if none are included.
  public func has(_ types: StateType...) -> Bool {
    guard types.count > 0 else {
      return self != .none
    }

    for type in types {
      if type == .all { return self == .all }
      if self.intersection(type) != .none { return true }
    }

    return false
  }
}
