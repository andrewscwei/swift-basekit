// © Sybl

import Foundation

/// Associated value for storing weakly referenced observers of the object conforming to `Observable`.
private var ptr_observers: UInt8 = 0

/// A protocol that makes the conforming object observable by observers. Subsequently, its observers must conform to its associated type `Observer` in order complete the observable-observer relationship.
public protocol Observable: AnyObject {

  /// An object must conform to this associated type in order to be an eligible observer of this `Observable`.
  associatedtype Observer: AnyObject

  /// Adds a weakly referenced observer to this `Observable`.
  ///
  /// - Parameter observer: The observer to add.
  func addObserver(_ observer: Observer)

  /// Removes an existing weakly referenced observer from this `Observable`.
  ///
  /// - Parameter observer: The observer to remove.
  func removeObserver(_ observer: Observer)

  /// Iterator function for all registered observers.
  ///
  /// - Parameter iterator: The iterator closure with each observer as the argument.
  func notifyObservers(iterator: (Observer) -> Void)
}

extension Observable {

  private var observers: [WeakReference<Observer>] {
    get { return getAssociatedValue(for: self, key: &ptr_observers, defaultValue: { [] }) }
    set { return setAssociatedValue(for: self, key: &ptr_observers, value: newValue) }
  }

  public func addObserver(_ observer: Observer) {
    for o in observers {
      guard o.get() !== observer else { return }
    }

    observers.append(WeakReference(observer))
  }

  public func removeObserver(_ observer: Observer) {
    var idx = -1

    for (i, v) in observers.enumerated() {
      if v.get() === observer {
        idx = i
        break
      }
    }

    if idx > -1 {
      observers.remove(at: idx)
    }
  }

  public func notifyObservers(iterator: (Observer) -> Void) {
    for ref in observers {
      guard let observer = ref.get() else { continue }
      iterator(observer)
    }
  }
}
