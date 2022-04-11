// © GHOZT

import Foundation

/// Associated value for storing weakly referenced observers.
private var ptr_observers: UInt8 = 0

/// An object conforming to the `Observable` protocol becomes observable, maintaining weak
/// references of its observers so it can notify them when certain events happen. Observers conform
/// to the associated `Observer` type and define their own event handlers.
public protocol Observable: AnyObject {

  /// A type must conform to this associated type to become a valid observer of this `Observable`.
  associatedtype Observer = AnyObject

  /// Adds a weakly referenced observer.
  ///
  /// - Parameter observer: The observer to add.
  func addObserver(_ observer: Observer)

  /// Removes an existing observer.
  ///
  /// - Parameter observer: The observer to remove.
  func removeObserver(_ observer: Observer)

  /// Iteratively executes a block on each registered observer.
  ///
  /// - Parameter iterator: The block to execute, with each registered observer as the argument.
  func notifyObservers(iterator: (Observer) -> Void)
}

extension Observable {

  private var observers: [WeakReference<Observer>] {
    get { return getAssociatedValue(for: self, key: &ptr_observers, defaultValue: { [] }) }
    set { return setAssociatedValue(for: self, key: &ptr_observers, value: newValue) }
  }

  public func addObserver(_ observer: Observer) {
    observers = observers.filter { $0.get() as AnyObject !== observer as AnyObject } + [WeakReference(observer)]
  }

  public func removeObserver(_ observer: Observer) {
    observers = observers.filter { $0.get() as AnyObject !== observer as AnyObject }
  }

  public func notifyObservers(iterator: (Observer) -> Void) {
    for o in observers {
      guard let observer = o.get() else { continue }
      iterator(observer)
    }
  }
}
