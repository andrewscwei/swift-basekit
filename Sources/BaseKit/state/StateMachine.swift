// © GHOZT

/// A state container that manages stateful properties for an object and emits
/// an event to the object whenever those properties are modified. The object
/// assumes the role of the delegate and must conform to the protocol
/// `StateMachineDelegate`.
///
/// `StateMachine` manages a set of stateful properties, or *states* for short,
/// as specified by the delegate via the `Stateful` property wrapper. When the
/// value of a state changes, the delegate will be notified, which can then
/// handle the entire update cycle inside its `update(check:)` method. Note that
/// multiple states can be simultaneously "dirty" in the same update cycle.
///
/// The delegate must explicitly invoke `start()` on its `StateMachine` instance
/// before it can begin monitoring state changes. Likewise, the delegate must
/// invoke `stop()` to pause or stop the `StateMachine`.
public class StateMachine {

  private weak var delegate: StateMachineDelegate?

  /// Indicates whether this `StateMachine` is running.
  public private(set) var isRunning: Bool = false

  /// Indicates whether an update transaction has been initiated but has yet to
  /// be committed.
  public private(set) var isInTransaction: Bool = false

  /// State types that are currently dirty.
  private var dirtyStateTypes: StateType = .all

  /// A set of key paths (with respect to the linked property of the
  /// `StateMachineDelegate`) of managed states that are currently dirty. A
  /// `nil` value indicates that every managed state is dirty, whereas an empty
  /// set indicates that no states are dirty.
  private var dirtyStateKeyPaths: Set<AnyKeyPath>?

  public init(_ delegate: StateMachineDelegate) {
    self.delegate = delegate
  }

  /// Begins capturing state updates.
  public func start() {
    guard !isRunning else { return }
    isRunning = true
    notifyStateUpdate()
  }

  /// Stops capturing state updates.
  public func stop() {
    isRunning = false
    isInTransaction = false

    // Whenever `StateMachine` stops, mark every state as dirty so that all
    // states will be invalidated upon calling the next `start()`.
    setDirty()
  }

  /// Initiates a new update *transaction*. A *transaction* allows you to modify
  /// multiple states before triggering an update cycle. Until the *transaction*
  /// is explicitly committed by invoking `commit()`, changes to states will not
  /// trigger an update cycle.
  public func beginTransaction() {
    guard !isInTransaction else { return }
    isInTransaction = true
  }

  /// Commits the current *transaction*, if it exists, consequently triggering
  /// an update cycle. All modified states up to this point will be marked as
  /// dirty in this update cycle.
  public func commit() {
    guard isInTransaction else { return }
    isInTransaction = false
    notifyStateUpdate()
  }

  /// Marks all key paths and state types as dirty, consequently triggering an
  /// update cycle.
  public func invalidateAll() {
    setDirty()

    notifyStateUpdate()
  }

  /// Marks the specified key path(s) as dirty, consequently triggering an
  /// update cycle.
  ///
  /// - Parameters:
  ///   - keyPaths: The key path(s) (relative to the property owner) to mark as
  ///               dirty.
  public func invalidate(_ keyPaths: AnyKeyPath...) {
    for keyPath in keyPaths {
      setDirty(keyPath)
    }

    notifyStateUpdate()
  }

  /// Marks the specified state type(s) as dirty, consequently triggering an
  /// update cycle.
  ///
  /// - Parameters:
  ///   - types: The state type(s) to mark as dirty.
  public func invalidate(_ types: StateType...) {
    for type in types {
      setDirty(type)
    }

    notifyStateUpdate()
  }

  /// Notifies the delegate that state updates are available. If other states
  /// are modified in the middle of this update cycle, a nested update cycle
  /// will take place to resolve those changes before the parent update cycle
  /// can continue.
  private func notifyStateUpdate() {
    guard !isInTransaction else { return }
    guard isRunning else { return }

    let checker = StateValidator.init(keyPaths: dirtyStateKeyPaths, stateTypes: dirtyStateTypes)

    clean()
    delegate?.update(check: checker)
  }

  /// Marks all state key paths and state types as dirty.
  private func setDirty() {
    dirtyStateTypes = .all
    dirtyStateKeyPaths = nil
  }

  /// Marks a state key path as dirty.
  ///
  /// - Parameters:
  ///   - keyPath: The state key path.
  private func setDirty(_ keyPath: AnyKeyPath) {
    dirtyStateKeyPaths?.insert(keyPath)
  }

  /// Marks a state type as dirty.
  ///
  /// - Parameters:
  ///   - type: The state type.
  private func setDirty(_ type: StateType) {
    dirtyStateTypes.insert(type)
  }

  /// Marks all state key paths and state types as **not** dirty.
  private func clean() {
    dirtyStateKeyPaths = []
    dirtyStateTypes = .none
  }
}
