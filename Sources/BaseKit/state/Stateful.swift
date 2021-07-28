// © Sybl

import Foundation

/// Links a property of a `StateMachineDelegate` to its `StateMachine`, transforming the property into a managed *state*. Whenever the value of this property changes, the `StateMachine` emits an update event to the `StateMachineDelegate`. Optional types are supported.
///
/// When transforming this property into a state, you can optionally assign more than one `StateType` to it by specifying the first parameter of this property wrapper. When the value of the state is changed, its key path (of the original property) is marked as dirty along with all its associated state types.
///
/// To conditionally prevent a new value to be assigned, you can specify the `willSet` parameter which is a closure with the old value and new value as arguments, respectively, that must be satisfied whenever a new value is assigned to the state.
///
/// To handle the event that a new value is successfully assigned, you can provide the `didSet` parameter, which is a closure consisting of the old value and the new value as arguments, respectively. This parameter should not be confused with the native `didSet` block of Swift properties. The difference is that the `didSet` parameter of this property wrapper only triggers when the state value has changed, whereas the native `didSet` block gets triggered regardless of whether the value was changed. You can achieve the same behavior with the native `didSet` block by utilizing the `projectedValue` of this property wrapper and checking the `isDirty` flag:
///
/// ```
/// @Stateful var foo: String = "foo" {
///   didSet {
///     if $foo.isDirty {
///       // Do something when the value has changed
///     }
///   }
/// }
/// ```
///
/// **Warning**: This property wrapper uses private API and causes segmentation fault in the compiler if the type constraint of the property owner is not satisfied.
@propertyWrapper
public struct Stateful<T> {

  public typealias WillSet = (T, T) -> Bool
  public typealias DidSet = (T, T) -> Void

  /// Indicates if the wrapped value has changed. This is useful when accessed via the projected value in `didSet` of the wrapped property, since `didSet` triggers regardless of whether the value has changed.
  public private(set) var isDirty: Bool = false

  /// Value semantics to prevent the standard `wrappedValue` member from being mutated.
  @available(*, unavailable, message: "The Stateful property wrapper can only be applied to StateMachineDelegate properties")
  public var wrappedValue: T {
    get { fatalError() }
    set { fatalError() }
  }

  /// Alternate member for storing the intended wrapped value.
  private var storageValue: T

  /// Projected value accessible by prefixing the wrapped property with `$`.
  public var projectedValue: Stateful<T> { self }

  /// The type of this state. A state can belong to multiple types or it can belong to no type.
  private let stateType: StateType?

  /// Boolean closure that must be satisfied in order to assign a new value to the wrapped property.
  private let willSet: WillSet

  /// Handler invoked when the a new value is assigned to the wrapped property.
  private let didSet: DidSet

  /// Private Swift API for getting/setting the wrapped value.
  public static subscript<EnclosingSelf: StateMachineDelegate>(_enclosingInstance owner: EnclosingSelf, wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, T>, storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Stateful<T>>) -> T {

    get { owner[keyPath: storageKeyPath].storageValue }

    set {
      let oldValue = owner[keyPath: storageKeyPath].storageValue

      guard owner[keyPath: storageKeyPath].willSet(oldValue, newValue) else {
        owner[keyPath: storageKeyPath].isDirty = false
        return
      }

      owner[keyPath: storageKeyPath].storageValue = newValue
      owner[keyPath: storageKeyPath].isDirty = true
      owner[keyPath: storageKeyPath].didSet(oldValue, newValue)
      owner.stateMachine.beginTransaction()
      owner.stateMachine.invalidate(wrappedKeyPath)
      if let stateType = owner[keyPath: storageKeyPath].stateType { owner.stateMachine.invalidate(stateType) }
      owner.stateMachine.commit()
    }
  }

  public init(_ stateType: StateType? = nil, willSet: WillSet? = nil, didSet: DidSet? = nil) where T : ExpressibleByNilLiteral {
    self.init(wrappedValue: nil, stateType, willSet: willSet, didSet: didSet)
  }

  public init(wrappedValue: T, _ stateType: StateType? = nil, willSet: WillSet? = nil, didSet: DidSet? = nil) where T : Equatable {
    storageValue = wrappedValue
    self.stateType = stateType
    self.willSet = willSet ?? { oldValue, newValue in oldValue != newValue }
    self.didSet = didSet ?? { _, _ in }
  }

  public init(wrappedValue: T, _ stateType: StateType? = nil, willSet: WillSet? = nil, didSet: DidSet? = nil) {
    storageValue = wrappedValue
    self.stateType = stateType
    self.willSet = willSet ?? { _, _ in true }
    self.didSet = didSet ?? { _, _ in }
  }
}
