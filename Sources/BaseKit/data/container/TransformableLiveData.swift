// © GHOZT

import Foundation

/// A type of `LiveData` whose wrapped value is a transformed result of the
/// wrapped value of another `LiveData`.
public class TransformableLiveData<T: Equatable, V: Equatable>: LiveData<T> {
  private let mapValue: (V?) -> T?

  let liveData: LiveData<V>

  /// Creates a new `TransformableLiveData` instance.
  ///
  /// - Parameters:
  ///   - liveData: The `LiveData` whose wrapped value will be used to compose
  ///               the wrapped value of the internal wrapped value.
  ///   - mapValue: A block that maps the `LiveData`'s wrapped value to the
  ///               internal wrapped value.
  public init(_ liveData: LiveData<V>, mapValue: @escaping (V?) -> T?) {
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

public class FooLiveData<T: Equatable, V0: Equatable, V1: Equatable>: LiveData<T> {
  public let mapValue: (V0?, V1?) -> T?

  let liveData0: LiveData<V0>
  let liveData1: LiveData<V1>

  public init(_ liveData0: LiveData<V0>, _ liveData1: LiveData<V1>, mapValue: @escaping (V0?, V1?) -> T?) {
    self.liveData0 = liveData0
    self.liveData1 = liveData1
    self.mapValue = mapValue

    super.init()

    currentValue = mapValue(liveData0.value, liveData1.value)

    liveData0.observe(for: self) { self.value = self.mapValue($0, self.liveData1.value) }
    liveData1.observe(for: self) { self.value = self.mapValue(self.liveData0.value, $0) }
  }

  deinit {
    liveData0.unobserve(for: self)
    liveData1.unobserve(for: self)
  }
}
