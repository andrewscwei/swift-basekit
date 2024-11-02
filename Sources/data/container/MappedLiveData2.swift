import Foundation

/// A `LiveData` type with a value mapped from two `LiveData` values.
public class MappedLiveData2<T: Equatable, L0: Equatable, L1: Equatable>: LiveData<T>, @unchecked Sendable {
  public let map: (L0?, L1?) -> T?

  let liveData0: LiveData<L0>
  let liveData1: LiveData<L1>

  public init(_ liveData0: LiveData<L0>, _ liveData1: LiveData<L1>, map: @escaping (L0?, L1?) -> T?) {
    self.liveData0 = liveData0
    self.liveData1 = liveData1
    self.map = map

    super.init()

    currentValue = map(liveData0.value, liveData1.value)

    liveData0.observe(for: self) { self.value = self.map($0, self.liveData1.value) }
    liveData1.observe(for: self) { self.value = self.map(self.liveData0.value, $0) }
  }

  deinit {
    liveData0.unobserve(for: self)
    liveData1.unobserve(for: self)
  }
}
