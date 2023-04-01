// © GHOZT

import Foundation

/// Wraps a value to allow passing it as an immutable reference.
public class Reference<T> {
  /// The wrapped value.
  public fileprivate(set) var value: T

  /// Creates a new `Reference` instance.
  ///
  /// - Parameters:
  ///   - value: The wrapped value.
  public init(value: T) {
    self.value = value
  }
}

/// Wraps a value to allow passing it as a mutable reference.
public class MutableReference<T>: Reference<T> {
  /// Updates the wrapped value.
  ///
  /// - Parameters:
  ///   - updater: A block that takes the current value as its argument. The
  ///              returned value of this block becomes the new wrapped value.
  public func update(updater: (T) -> T) {
    let oldValue = value
    value = updater(oldValue)
  }
}
