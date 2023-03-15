// © GHOZT

import Foundation

/// A type of `RepositoryLiveData` that permits modifying of its wrapped value
/// from externally, subsequently modifying the value of the associated
/// `Repository`.
public typealias MutableRepositoryLiveData<T: Codable & Equatable> = MutableTransformableRepositoryLiveData<T, T>

/// A type of `TransformableRepositoryLiveData` that permits modifying of its
/// wrapped value from externally, subsequently modifying the value of the
/// associated `Repository`.
public class MutableTransformableRepositoryLiveData<T: Codable & Equatable, R: Codable & Equatable>: TransformableRepositoryLiveData<T, R> {
  private let mapValueToRepositoryValue: (T) -> R

  /// Creates a new `MutableTransformableRepositoryLiveData` instance and
  /// immediately assigns its wrapped value to the `Repository` value. If the
  /// `Repository` is not synced, the wrapped value would be `nil` and a sync
  /// will be invoked where observers can anticipate the synced value upon the
  /// next change event.
  ///
  /// - Parameters:
  ///   - repository: The `Repository` to provide the wrapped value.
  ///   - mapRepositoryValueToValue: A block that maps the repository value to
  ///                                the wrapped value.
  ///   - mapValueToRepositoryValue: A block that maps the wrapped value to the
  ///                                repository value.
  public init(_ repository: Repository<R>, mapRepositoryValueToValue: @escaping (R) -> T, mapValueToRepositoryValue: @escaping (T) -> R) {
    self.mapValueToRepositoryValue = mapValueToRepositoryValue
    super.init(repository, mapRepositoryValueToValue: mapRepositoryValueToValue)
  }

  /// Creates a new `MutableTransformableRepositoryLiveData` instance and
  /// immediately assigns its wrapped value to the `Repository` value. If the
  /// `Repository` is not synced, the wrapped value would be `nil` and a sync
  /// will be invoked where observers can anticipate the synced value upon the
  /// next change event.
  ///
  /// - Parameters:
  ///   - repository: The `Repository` to provide the wrapped value.
  public convenience init(_ repository: Repository<T>) where R == T {
    self.init(repository, mapRepositoryValueToValue: { $0 }, mapValueToRepositoryValue: { $0 })
  }

  /// Sets the wrapped value, subsequently updating the repository value.
  ///
  /// - Parameters:
  ///   - newValue: The new wrapped value.
  ///
  /// - Throws: If the repository is not writable.
  public func setValue(_ newValue: T?) throws {
    guard value != newValue else { return }

    if let repository = repository as? ReadWriteDeleteRepository<R> {
      if let newValue = newValue {
        return repository.set(mapValueToRepositoryValue(newValue))
      }
      else {
        return repository.delete()
      }
    }
    else if let repository = repository as? ReadWriteRepository<R> {
      if let newValue = newValue {
        return repository.set(mapValueToRepositoryValue(newValue))
      }
    }

    throw LiveDataError.notWritable(cause: nil)
  }

  /// Sets the wrapped value by directly mutating the existing wrapped value
  /// (changes made to the wrapped value inside the `mutator` block will also be
  /// applied outside the block).
  ///
  /// - Parameters:
  ///   - mutator: The mutator block.
  public func setValue(mutator: (inout T) throws -> Void) throws {
    guard var newValue = value else { throw LiveDataError.notWritable(cause: nil) }

    try mutator(&newValue)
    try setValue(newValue)
  }
}
