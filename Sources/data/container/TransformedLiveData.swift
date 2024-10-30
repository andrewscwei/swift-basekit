import Foundation

/// A type of `LiveData` whose wrapped value is a transformed result of the
/// wrapped value of another `LiveData`.
public class TransformedLiveData<T: Equatable, L: Equatable>: LiveData<T> {
  private let transform: (L?) -> T?

  let liveData: LiveData<L>

  /// Creates a new `TransformedLiveData` instance.
  ///
  /// - Parameters:
  ///   - liveData: The `LiveData` whose wrapped value will be used to compose
  ///               the wrapped value of the internal wrapped value.
  ///   - transform: A block that maps the `LiveData`'s wrapped value to the
  ///                internal wrapped value.
  public init(_ liveData: LiveData<L>, transform: @escaping (L?) -> T?) {
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
