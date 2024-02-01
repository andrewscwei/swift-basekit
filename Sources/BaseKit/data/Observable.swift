import Foundation

/// Associated value for storing weakly referenced observers.
private var ptr_observers: UInt8 = 0

/// An object conforming to the `Observable` protocol becomes observable,
/// storing weak references of its registered observers so it can notify them
/// when certain events happen. Observers conform to the associated `Observer`
/// type and define their own event handlers.
public protocol Observable: AnyObject {
  /// A type must conform to this associated type to become a valid observer of
  /// this `Observable`.
  associatedtype Observer = AnyObject

  /// Registers a weakly referenced observer.
  ///
  /// - Parameters:
  ///   - observer: The observer to add.
  func addObserver(_ observer: Observer)

  /// Unregisters an existing observer.
  ///
  /// - Parameters:
  ///   - observer: The observer to remove.
  func removeObserver(_ observer: Observer)

  /// Iteratively executes a block on each registered observer.
  ///
  /// - Parameters:
  ///   - iteratee: The block to execute with each registered observer as the
  ///               parameter.
  func notifyObservers(iteratee: (Observer) -> Void)
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

  public func notifyObservers(iteratee: (Observer) -> Void) {
    for o in observers {
      guard let observer = o.get() else { continue }
      iteratee(observer)
    }
  }
}
