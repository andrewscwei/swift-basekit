/// An immutable object holding a weak reference to a target set during
/// initialization, or passed as a value if it’s a value type.
public struct WeakReference<T> {
  private let getReference: () -> T?

  /// Creates a new `WeakReference` instance.
  ///
  /// - Parameters:
  ///   - object: The target object to store as a weak reference, passed as a
  ///             value if it’s a value type.
  public init(_ object: T) {
    let reference = object as AnyObject

    getReference = { [weak reference] in
      reference as? T
    }
  }

  /// Returns the unwrapped object. As it’s weakly referenced, it may not exist
  /// in memory (except for value types).
  ///
  /// - Returns: The unwrapped object (if it still exists).
  public func get() -> T? { getReference() }
}
