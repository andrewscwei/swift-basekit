import Foundation

/// A type of `LiveData` whose wrapped value can be modified.
public class MutableLiveData<T: Equatable>: LiveData<T>, @unchecked Sendable {

  /// Sets the wrapped value.
  ///
  /// - Parameters:
  ///   - value: The new wrapped value.
  public func setValue(_ newValue: T?) {
    value = newValue
  }
}
