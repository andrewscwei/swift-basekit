// © GHOZT

import Foundation

/// A helper object that checks if any of the states or state types managed by a
/// `StateMachine` is dirty.
public struct StateValidator {

  private let dirtyStateKeyPaths: Set<AnyKeyPath>?
  private let dirtyStateTypes: StateType

  public init(keyPaths: Set<AnyKeyPath>? = nil, stateTypes: StateType = .all) {
    dirtyStateKeyPaths = keyPaths
    dirtyStateTypes = stateTypes
  }

  /// Checks if the provided states are dirty in the current `StateMachine`
  /// update cycle by looking up their respective key paths.
  ///
  /// - Parameters:
  ///   - keyPaths: The key paths of the states.
  ///
  /// - Returns: `true` if at least one state is dirty, `false` if none are
  ///   dirty.
  public func isDirty(_ keyPaths: AnyKeyPath...) -> Bool {
    guard let dirtyStateKeyPaths = dirtyStateKeyPaths else { return true }

    for keyPath in keyPaths {
      if dirtyStateKeyPaths.contains(keyPath) == true {
        return true
      }
    }

    return false
  }

  /// Checks if the provided state types are dirty in the current `StateMachine`
  /// update cycle.
  ///
  /// - Parameters:
  ///   - types: The state types. This can be a signle `StateType` or an option
  ///            set `StateType`, either works.
  ///
  /// - Returns: `true` if at least one state type is dirty, `false` if none are
  ///            dirty.
  public func isDirty(_ types: StateType...) -> Bool {
    for type in types {
      if dirtyStateTypes.has(type) {
        return true
      }
    }

    return false
  }
}
