// © Sybl

import Foundation

/// Wraps an immutable value to allow passing it as a reference.
public class Reference<T> {

  /// The wrapped value.
  public fileprivate(set) var value: T

  public init(value: T) {
    self.value = value
  }
}

/// Wraps a mutable value to allow passing it as a reference.
public class MutableReference<T>: Reference<T> {

  /// Updates the wrapped value.
  ///
  /// - Parameter execute: A block that takes the current value as its argument. The returned value
  ///                      of this block becomes the new wrapped value.
  public func update(execute: (T) -> T) {
    let oldValue = value
    value = execute(oldValue)
  }
}
