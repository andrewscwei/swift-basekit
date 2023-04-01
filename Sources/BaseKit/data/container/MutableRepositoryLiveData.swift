// © GHOZT

import Foundation

/// A type of `RepositoryLiveData` that permits modifying of its wrapped value
/// from externally, subsequently modifying the value in the `Repository`.
public class MutableRepositoryLiveData<T, R: Codable & Equatable>: RepositoryLiveData<T, R> {
  private let reverseTransform: (T, R?) -> R

  /// Creates a new `MutableRepositoryLiveData` instance and immediately assigns
  /// its wrapped value with the `Repository` value. If the `Repository` is not
  /// synced, the wrapped value would be `nil` and a sync will be invoked on the
  /// repository.
  ///
  /// Registered observers are notified every time the value of the `Repository`
  /// changes.
  ///
  /// - Parameters:
  ///   - repository: The `Repository` to provide the wrapped value.
  ///   - transform: A block that transforms the current repository value and
  ///                wrapped value into the new wrapped value. This block is
  ///                only called on a synced repository value.
  ///   - reverseTransform: A block that transforms the current wrapped value
  ///                       and repository value into the new repository value.
  ///                       If the current repository value is not synced, `nil`
  ///                       will be passed to the block.
  public init(_ repository: Repository<R>, transform: @escaping (R, T?) -> T?, reverseTransform: @escaping (T, R?) -> R) {
    self.reverseTransform = reverseTransform
    super.init(repository, transform: transform)
  }

  /// Creates a new `MutableRepositoryLiveData` instance and immediately assigns
  /// its wrapped value with the `Repository` value. If the `Repository` is not
  /// synced, the wrapped value would be `nil` and a sync will be invoked on the
  /// repository.
  ///
  /// Registered observers are notified every time the value of the `Repository`
  /// changes.
  ///
  /// - Parameters:
  ///   - repository: The `Repository` to provide the wrapped value.
  ///   - transform: A block that transforms the current repository value and
  ///                wrapped value into the new wrapped value. This block is
  ///                only called on a synced repository value.
  ///   - reverseTransform: A block that transforms the current wrapped value
  ///                       into the new repository value. If the current
  ///                       repository value is not synced, `nil` will be passed
  ///                       to the block.
  public convenience init(_ repository: Repository<R>, transform: @escaping (R, T?) -> T?, reverseTransform: @escaping (T) -> R) {
    self.init(repository, transform: transform, reverseTransform: { value, _ in reverseTransform(value) })
  }

  /// Creates a new `MutableRepositoryLiveData` instance and immediately assigns
  /// its wrapped value with the `Repository` value. If the `Repository` is not
  /// synced, the wrapped value would be `nil` and a sync will be invoked on the
  /// repository.
  ///
  /// Registered observers are notified every time the value of the `Repository`
  /// changes.
  ///
  /// - Parameters:
  ///   - repository: The `Repository` to provide the wrapped value.
  ///   - transform: A block that transforms the current repository value into
  ///                the new wrapped value. This block is only called on a
  ///                synced repository value.
  ///   - reverseTransform: A block that transforms the current wrapped value
  ///                       and repository value into the new repository value.
  ///                       If the current repository value is not synced, `nil`
  ///                       will be passed to the block.
  public convenience init(_ repository: Repository<R>, transform: @escaping (R) -> T?, reverseTransform: @escaping (T, R?) -> R) {
    self.init(repository, transform: { value, _ in transform(value) }, reverseTransform: reverseTransform)
  }

  /// Creates a new `MutableRepositoryLiveData` instance and immediately assigns
  /// its wrapped value with the `Repository` value. If the `Repository` is not
  /// synced, the wrapped value would be `nil` and a sync will be invoked on the
  /// repository.
  ///
  /// Registered observers are notified every time the value of the `Repository`
  /// changes.
  ///
  /// - Parameters:
  ///   - repository: The `Repository` to provide the wrapped value.
  ///   - transform: A block that transforms the current repository value into
  ///                the new wrapped value. This block is only called on a
  ///                synced repository value.
  ///   - reverseTransform: A block that transforms the current wrapped value
  ///                       into the new repository value. If the current
  ///                       repository value is not synced, `nil` will be passed
  ///                       to the block.
  public convenience init(_ repository: Repository<R>, transform: @escaping (R) -> T?, reverseTransform: @escaping (T) -> R) {
    self.init(repository, transform: { value, _ in transform(value) }, reverseTransform: { value, _ in reverseTransform(value) })
  }

  /// Creates a new `MutableRepositoryLiveData` instance and immediately assigns
  /// its wrapped value to the `Repository` value. If the `Repository` is not
  /// synced, the wrapped value would be `nil` and a sync will be invoked where
  /// observers can anticipate the synced value upon the next change event.
  ///
  /// - Parameters:
  ///   - repository: The `Repository` to provide the wrapped value.
  public convenience init(_ repository: Repository<R>) where R == T {
    self.init(repository, transform: { $0 }, reverseTransform: { $0 })
  }

  /// Sets the wrapped value, subsequently updating the repository value.
  ///
  /// - Parameters:
  ///   - newValue: The new wrapped value.
  ///
  /// - Throws: If the repository is not writable.
  public func setValue(_ newValue: T?) throws {
    guard !isEqual(value, newValue) else { return }

    if let repository = repository as? ReadWriteDeleteRepository<R> {
      if let newValue = newValue {
        switch repository.getCurrent() {
        case .notSynced:
          return repository.set(reverseTransform(newValue, nil))
        case .synced(let currentRepositoryValue):
          return repository.set(reverseTransform(newValue, currentRepositoryValue))
        }
      }
      else {
        return repository.delete()
      }
    }
    else if let repository = repository as? ReadWriteRepository<R> {
      if let newValue = newValue {
        switch repository.getCurrent() {
        case .notSynced:
          return repository.set(reverseTransform(newValue, nil))
        case .synced(let currentRepositoryValue):
          return repository.set(reverseTransform(newValue, currentRepositoryValue))
        }
      }
    }

    throw LiveDataError.immutable(cause: nil)
  }

  /// Sets the wrapped value by directly mutating the existing wrapped value
  /// (changes made to the wrapped value inside the `mutator` block will also be
  /// applied outside the block).
  ///
  /// - Parameters:
  ///   - mutator: The mutator block.
  public func setValue(mutator: (inout T) throws -> Void) throws {
    guard var newValue = value else { throw LiveDataError.immutable(cause: nil) }

    try mutator(&newValue)
    try setValue(newValue)
  }
}
