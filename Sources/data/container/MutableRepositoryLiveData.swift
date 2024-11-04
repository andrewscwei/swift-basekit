import Foundation

/// A `RepositoryLiveData` type allowing external modification of its wrapped
/// value, which updates the `Repository` accordingly.
public class MutableRepositoryLiveData<T: Equatable, R: Repository>: RepositoryLiveData<T, R>, @unchecked Sendable {
  private let unmap: (T, R.DataType?) -> R.DataType

  /// Creates a `MutableRepositoryLiveData` instance, assigning its value to the
  /// `Repository` value. If unsynced, the value is `nil`, triggering a sync.
  ///
  /// Observers are notified on every `Repository` value change.
  ///
  /// - Parameters:
  ///   - repository: The `Repository` providing the wrapped value.
  ///   - map: A block transforming the repository and current value into the
  ///          new wrapped value, called only when synced.
  ///   - unmap: A block transforming the wrapped and repository values into a
  ///            new repository value. `nil` is passed if the repository value
  ///            isn't synced.
  public init(_ repository: R, map: @escaping @Sendable (R.DataType, T?) -> T?, unmap: @escaping @Sendable (T, R.DataType?) -> R.DataType) {
    self.unmap = unmap

    super.init(repository, map: map)
  }

  /// Creates a `MutableRepositoryLiveData` instance, assigning its value to the
  /// `Repository` value. If unsynced, the value is `nil`, triggering a sync.
  ///
  /// Observers are notified on each `Repository` value change.
  ///
  /// - Parameters:
  ///   - repository: The `Repository` providing the wrapped value.
  ///   - map: A block transforming the repository and current value into the
  ///          new wrapped value, called only when synced.
  ///   - unmap: A block transforming the wrapped value into a new repository
  ///            value. `nil` is passed if the repository isn't synced.
  public convenience init(_ repository: R, map: @escaping @Sendable (R.DataType, T?) -> T?, unmap: @escaping @Sendable (T) -> R.DataType) {
    self.init(repository, map: map, unmap: { value, _ in unmap(value) })
  }

  /// Creates a `MutableRepositoryLiveData` instance, assigning its value to the
  /// `Repository` value. If unsynced, the value is `nil`, triggering a sync.
  ///
  /// Observers are notified on each `Repository` value change.
  ///
  /// - Parameters:
  ///   - repository: The `Repository` providing the wrapped value.
  ///   - map: A block transforming the repository value into the new wrapped
  ///          value, called only when synced.
  ///   - unmap: A block transforming the wrapped and repository values into a
  ///            new repository value. `nil` is passed if unsynced.
  public convenience init(_ repository: R, map: @escaping @Sendable (R.DataType) -> T?, unmap: @escaping @Sendable (T, R.DataType?) -> R.DataType) {
    self.init(repository, map: { value, _ in map(value) }, unmap: unmap)
  }

  /// Creates a `MutableRepositoryLiveData` instance, assigning its value to the
  /// `Repository` value. If unsynced, the value is `nil`, triggering a sync.
  ///
  /// Observers are notified on each `Repository` value change.
  ///
  /// - Parameters:
  ///   - repository: The `Repository` providing the wrapped value.
  ///   - map: A block transforming the repository value into the new wrapped
  ///          value, called only when synced.
  ///   - unmap: A block transforming the wrapped value into a new repository
  ///            value. `nil` is passed if unsynced.
  public convenience init(_ repository: R, map: @escaping @Sendable (R.DataType) -> T?, unmap: @escaping @Sendable (T) -> R.DataType) {
    self.init(repository, map: { value, _ in map(value) }, unmap: { value, _ in unmap(value) })
  }

  /// Creates a `MutableRepositoryLiveData` instance, assigning its value to the
  /// `Repository` value. If unsynced, the value is `nil`, triggering a sync.
  /// Observers will receive the synced value on the next change event.
  ///
  /// - Parameters:
  ///   - repository: The `Repository` providing the wrapped value.
  public convenience init(_ repository: R) where R.DataType == T {
    self.init(repository, map: { $0 }, unmap: { $0 })
  }

  /// Sets the wrapped value, updating the repository value.
  ///
  /// - Parameters:
  ///   - newValue: The new wrapped value.
  ///
  /// - Throws: If the repository is not writable.
  public func setValue(_ newValue: T?) throws where R: ReadWriteDeleteRepository {
    if let newValue = newValue {
      Task {
        switch await repository.getState() {
        case .initial:
          try await repository.set(unmap(newValue, nil))
        case .synced(let data), .notSynced(let data):
          try await repository.set(unmap(newValue, data))
        }
      }
    }
    else {
      Task {
        try await repository.delete()
      }
    }
  }

  /// Sets the wrapped value, updating the repository value.
  ///
  /// - Parameters:
  ///   - newValue: The new wrapped value.
  ///
  /// - Throws: If the repository is not writable.
  public func setValue(_ newValue: T?) throws where R: ReadWriteRepository {
    if let newValue = newValue {
      Task {
        switch await repository.getState() {
        case .initial:
          try await repository.set(unmap(newValue, nil))
        case .synced(let data), .notSynced(let data):
          try await repository.set(unmap(newValue, data))
        }
      }
    }
  }

  /// Sets the wrapped value, updating the repository value.
  ///
  /// - Parameters:
  ///   - newValue: The new wrapped value.
  ///
  /// - Throws: If the repository is not writable.
  public func setValue(_ newValue: T?) throws {
    throw error("Attempting to set the value of a MutableRepositoryLiveData when the associated repository is readonly", domain: "BaseKit.LiveData")
  }

  /// Sets the wrapped value by directly mutating the existing value. Changes
  /// made inside the `mutate` block will also apply outside the block.
  ///
  /// - Parameters:
  ///   - mutate: The mutate block.
  public func setValue(mutate: (inout T) throws -> Void) throws {
    guard var newValue = value else {
      throw error("Attempting to mutate the value of a MutableRepositoryLiveData when it is nil", domain: "BaseKit.LiveData")
    }

    try mutate(&newValue)
    try setValue(newValue)
  }
}
