// © GHOZT

import Foundation

/// A type of `LiveData` whose wrapped value is a transformed result of the
/// wrapped value of another `LiveData`.
public class TransformedLiveData<T: Equatable, V: Equatable>: LiveData<T> {
  private let transform: (V?) -> T?

  let liveData: LiveData<V>

  /// Creates a new `TransformedLiveData` instance.
  ///
  /// - Parameters:
  ///   - liveData: The `LiveData` whose wrapped value will be used to compose
  ///               the wrapped value of the internal wrapped value.
  ///   - transform: A block that maps the `LiveData`'s wrapped value to the
  ///               internal wrapped value.
  public init(_ liveData: LiveData<V>, transform: @escaping (V?) -> T?) {
    self.liveData = liveData
    self.transform = transform

    super.init()

    currentValue = transform(liveData.value)

    liveData.observe(for: self) { value in
      self.value = self.transform(value)
    }
  }

  deinit {
    liveData.unobserve(for: self)
  }
}
