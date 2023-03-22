// © GHOZT

import Foundation

/// A type of `LiveData` whose wrapped value is a transformed result of two
/// `LiveData` wrapped values.
public class ComposedLiveData<T: Equatable, V0: Equatable, V1: Equatable>: LiveData<T> {
  public let transform: (V0?, V1?) -> T?

  let liveData0: LiveData<V0>
  let liveData1: LiveData<V1>

  public init(_ liveData0: LiveData<V0>, _ liveData1: LiveData<V1>, transform: @escaping (V0?, V1?) -> T?) {
    self.liveData0 = liveData0
    self.liveData1 = liveData1
    self.transform = transform

    super.init()

    currentValue = transform(liveData0.value, liveData1.value)

    liveData0.observe(for: self) { self.value = self.transform($0, self.liveData1.value) }
    liveData1.observe(for: self) { self.value = self.transform(self.liveData0.value, $0) }
  }

  deinit {
    liveData0.unobserve(for: self)
    liveData1.unobserve(for: self)
  }
}
