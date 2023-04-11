// © GHOZT

import Foundation

/// A type of `LiveData` whose wrapped value is the transformed result of the
/// wrapped values of four `LiveData`.
public class ComposedLiveData4<T: Equatable, L0: Equatable, L1: Equatable, L2: Equatable, L3: Equatable>: LiveData<T> {
  public let transform: (L0?, L1?, L2?, L3?) -> T?

  let liveData0: LiveData<L0>
  let liveData1: LiveData<L1>
  let liveData2: LiveData<L2>
  let liveData3: LiveData<L3>

  public init(_ liveData0: LiveData<L0>, _ liveData1: LiveData<L1>, _ liveData2: LiveData<L2>, _ liveData3: LiveData<L3>, transform: @escaping (L0?, L1?, L2?, L3?) -> T?) {
    self.liveData0 = liveData0
    self.liveData1 = liveData1
    self.liveData2 = liveData2
    self.liveData3 = liveData3
    self.transform = transform

    super.init()

    currentValue = transform(liveData0.value, liveData1.value, liveData2.value, liveData3.value)

    liveData0.observe(for: self) { self.value = self.transform($0, self.liveData1.value, self.liveData2.value, self.liveData3.value) }
    liveData1.observe(for: self) { self.value = self.transform(self.liveData0.value, $0, self.liveData2.value, self.liveData3.value) }
    liveData2.observe(for: self) { self.value = self.transform(self.liveData0.value, self.liveData1.value, $0, self.liveData3.value) }
    liveData3.observe(for: self) { self.value = self.transform(self.liveData0.value, self.liveData1.value, self.liveData2.value, $0) }
  }

  deinit {
    liveData0.unobserve(for: self)
    liveData1.unobserve(for: self)
    liveData2.unobserve(for: self)
    liveData3.unobserve(for: self)
  }
}
