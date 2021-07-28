// © Sybl

/// A wrapper object that stores another object as a weak reference.
public struct WeakReference<T: AnyObject> {

  public weak var object: T?

  /// Creates a new `WeakReference` instnace.
  ///
  /// - Parameter object: The target object to store as a weak reference.
  public init(_ object: T) {
    self.object = object
  }

  /// Unwraps and returns the wrapped object. Since the object is weakly referenced, there is no guarantee that the object still exists in memory when invoking this method.
  ///
  /// - Returns: The wrapped object if it still exists.
  public func get() -> T? { self.object }
}
