/// Value wrapper for passing as a mutable reference.
public class MutableReference<T>: Reference<T> {

  /// Updates the wrapped value.
  ///
  /// - Parameters:
  ///   - updater: A block that receives the current value and returns the new
  ///              wrapped value.
  public func update(updater: (T) -> T) {
    let oldValue = value
    value = updater(oldValue)
  }
}
