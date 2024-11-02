import Foundation

/// A type of `LiveData` with a value that is the mapped result of another
/// `LiveData`’s value.
public class MappedLiveData<T: Equatable, L: Equatable>: LiveData<T>, @unchecked Sendable {
  private let map: (L?) -> T?

  let liveData: LiveData<L>

  /// Creates a new `MappedLiveData` instance.
  ///
  /// - Parameters:
  ///   - liveData: The `LiveData` whose value is used to compose the internal
  ///               wrapped value.
  ///   - map: A block that maps the `LiveData`’s value to the internal wrapped
  ///          value.
  public init(_ liveData: LiveData<L>, map: @escaping (L?) -> T?) {
    self.liveData = liveData
    self.map = map

    super.init()

    currentValue = map(liveData.value)

    liveData.observe(for: self) { value in
      self.value = self.map(value)
    }
  }

  deinit {
    liveData.unobserve(for: self)
  }
}
