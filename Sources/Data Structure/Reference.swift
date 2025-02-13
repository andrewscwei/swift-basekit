/// Value wrapper for passing as an immutable reference.
public class Reference<T> {

  /// The wrapped value.
  public internal(set) var value: T

  /// Creates a new `Reference` instance.
  ///
  /// - Parameters:
  ///   - value: The value to wrap.
  public init(value: T) {
    self.value = value
  }
}
