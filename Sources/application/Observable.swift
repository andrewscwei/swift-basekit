/// An object conforming to the `Observable` protocol becomes observable,
/// storing weak references of its registered observers so it can notify them
/// when certain events happen. Observers conform to the associated `Observer`
/// type and define their own event handlers.
///
/// `associatedtype`:
///   - `Observer`: A type must conform to this associated type to become a
///                 valid observer of this `Observable`.
public protocol Observable: AnyObject {
  associatedtype Observer = AnyObject

  /// A collection of weakly referenced observers.
  var observers: [WeakReference<Observer>] { get set }

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
  public func addObserver(_ observer: Observer) {
    observers = observers.filter { $0.get() as AnyObject !== observer as AnyObject } + [WeakReference(observer)]
  }

  public func removeObserver(_ observer: Observer) {
    observers = observers.filter { $0.get() as AnyObject !== observer as AnyObject }
  }

  public func notifyObservers(iteratee: (Observer) -> Void) {
    observers.compactMap { $0.get() }.forEach(iteratee)
  }
}
