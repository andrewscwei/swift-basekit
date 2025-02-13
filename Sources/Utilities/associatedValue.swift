import Foundation

/// Returns the typed value associated with a given object for a given key. The
/// value is returned successfully if it exists and can be typecast to `T`.
/// Otherwise, `nil` is returned.
///
/// - Parameters:
///   - object: The object of which the value is associated with.
///   - key: The key through which the value is associated with the object.
/// - Returns: The associated value if it exists and can be typecast to `T`,
///            `nil` otherwise.
public func getAssociatedValue<T: Any>(for object: AnyObject, key: UnsafeRawPointer) -> T? {
  guard let value = objc_getAssociatedObject(object, key) as? T else { return nil }
  return value
}

/// Returns the typed value associated with a given object for a given key with
/// the option to provide a default value. The default value is only returned if
/// the associated value does not exist or it cannot be typecast to `T`. When
/// the default value is returned, it automatically gets stored as the new
/// associated value.
///
/// - Parameters:
///   - object: The object of which the value is associated with.
///   - key: The key through which the value is associated with the object.
///   - defaultValue: Block that returns the default value.
/// - Returns: The associated value if it exists and can be typecast to `T`,
///            otherwise the default value.
public func getAssociatedValue<T: Any>(for object: AnyObject, key: UnsafeRawPointer, defaultValue: () -> T) -> T {
  if let value = objc_getAssociatedObject(object, key) as? T {
    return value
  }

  let value = defaultValue()

  return value
}

/// Associates a value with a given object using a given key via a strong
/// reference to the associated object.
///
/// - Parameters:
///   - object: Object to associate the value with.
///   - key: The key through which the value is associated with the object.
///   - value: The associated value.
public func setAssociatedValue<T: Any>(for object: AnyObject, key: UnsafeRawPointer, value: T?) {
  objc_setAssociatedObject(object, key, value, .OBJC_ASSOCIATION_RETAIN)
}
