// © GHOZT

import Foundation

/// An object conforming to this protocol assumes the delegate of a
/// `StateMachine` and handles its state update cycles. An object cannot be a
/// delegate of more than one `StateMachine`.
public protocol StateMachineDelegate: AnyObject {

  /// The `StateMachine`.
  var stateMachine: StateMachine { get }

  /// The centralized handler of a `StateMachine` update cycle, invoked whenever
  /// a state managed by the `StateMachine` is modified or when a state type is
  /// marked as dirty by the `StateMachine`. This method is also invoked upon
  /// starting the `StateMachine`. If any states are modified during this update
  /// cycle, consequently triggering another update cycle, the new update cycle
  /// will be resolved first (handling changes for the states responsible for
  /// the new update cycle only) before returning to the current update cycle.
  ///
  /// - Parameters:
  ///   - check: A `DirtyStateChecker` instance containing the dirty state key
  ///            paths/state types of the `StateMachine` in the current update
  ///            cycle.
  func update(check: StateValidator)
}
