// © Sybl

import Foundation

/// Associated value for storing weakly referenced observers.
private var ptr_observers: UInt8 = 0

/// An object conforming to the `Observable` protocol becomes observable, maintaining weak
/// references of its observers so it can notify them when certain events happen. Observers conform
/// to the associated `Observer` type and define their own event handlers.
public protocol Observable: AnyObject {

  /// A type must conform to this associated type to become an eligible observer of this
  /// `Observable`.
  associatedtype Observer

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

  public func addObserver(_ observer: Observer) where Observer: AnyObject {
    for o in observers {
      guard o.get() !== observer else { return }
    }

    observers.append(WeakReference(observer))
  }

  public func addObserver(_ observer: Observer) {
    observers.append(WeakReference(observer))
  }

  public func removeObserver(_ observer: Observer) where Observer: AnyObject {
    var idx = -1

    for (i, o) in observers.enumerated() {
      if o.get() === observer {
        idx = i
        break
      }
    }

    if idx > -1 {
      observers.remove(at: idx)
    }
  }

  public func removeObserver(_ observer: Observer) {

  }

  public func notifyObservers(iterator: (Observer) -> Void) {
    for o in observers {
      guard let observer = o.get() else { continue }
      iterator(observer)
    }
  }
}
