// © GHOZT

import Foundation

/// A type of `LiveData` whose wrapped value is composed by the wrapped value of
/// another `LiveData`.
public class ComposedLiveData<T: Codable & Equatable, R: Codable & Equatable>: LiveData<T> {
  private let mapValue: (R?) -> T?

  let liveData: LiveData<R>

  /// Creates a new `ComposedLiveData` instance.
  ///
  /// - Parameters:
  ///   - liveData: The `LiveData` whose wrapped value will be used to compose
  ///               the wrapped value of the internal wrapped value.
  ///   - mapValue: A block that maps the `LiveData`'s wrapped value to the
  ///               internal wrapped value.
  public init(_ liveData: LiveData<R>, mapValue: @escaping (R?) -> T?) {
    self.liveData = liveData
    self.mapValue = mapValue

    super.init()

    currentValue = mapValue(liveData.value)

    liveData.observe(for: self) { value in
      self.value = self.mapValue(value)
    }
  }

  deinit {
    liveData.unobserve(for: self)
  }
}
