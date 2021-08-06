// © Sybl

/// A wrapper object that weakly references another object. Note that while value types can be wrapped in a
/// `WeakReference`, there is little meaning to it because it gets passed around as a value regardless.
public struct WeakReference<T> {

  private let provider: () -> T?

  /// Creates a new `WeakReference` instance.
  ///
  /// - Parameter object: The target object to store as a weak reference. Note that while value types can be
  ///   wrapped in a `WeakReference`, there is little meaning to it because it gets passed around as a value regardless.
  public init(_ object: T) {
    let reference = object as AnyObject

    provider = { [weak reference] in
      reference as? T
    }
  }

  /// Unwraps and returns the wrapped object. Since the object is weakly referenced, there is no guarantee that the
  /// object still exists in memory when invoking this method (this will not apply if a value type is wrapped).
  ///
  /// - Returns: The wrapped object if it still exists.
  public func get() -> T? { provider() }
}
