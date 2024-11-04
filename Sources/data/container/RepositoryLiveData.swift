import Foundation

/// A `LiveData` type that wraps a value `T` from a transformed `Repository`
/// value `R`.
public class RepositoryLiveData<T: Equatable, R: Syncable>: LiveData<T>, RepositoryObserver, @unchecked Sendable {
  private let map: (R, T?) -> T?

  let repository: Repository<R>

  /// Creates a `RepositoryLiveData` instance, assigning its value to a mapped
  /// `Repository` value. If unsynced, the initial value is `nil`, and a sync is
  /// triggered. Observers are notified on value changes.
  ///
  /// - Parameters:
  ///   - repository: The `Repository`.
  ///   - map: A block transforming the repository value into the new value.
  public convenience init(_ repository: Repository<R>, map: sending @escaping (R) -> T?) {
    self.init(repository) { value, _ in map(value) }
  }

  /// Creates a `RepositoryLiveData` instance, assigning its value to a mapped
  /// `Repository` value. If unsynced, the initial value is `nil`, triggering a
  /// sync. Observers are notified on value changes.
  ///
  /// - Parameters:
  ///   - repository: The `Repository`.
  ///   - map: A block transforming the repository and current value into the
  ///          new wrapped value.
  public init(_ repository: Repository<R>, map: sending @escaping (R, T?) -> T?) {
    self.repository = repository
    self.map = map

    super.init()

    repository.addObserver(self)

    Task {
      switch await repository.getState() {
      case .synced(let value), .notSynced(let value):
        currentValue = map(value, currentValue)
      case .initial:
        currentValue = nil
        sync()
      }
    }
  }

  /// Creates a `RepositoryLiveData` instance, assigning its value to the
  /// `Repository` value. If unsynced, the value is `nil`, triggering a sync,
  /// and observers will receive the synced value on the next change event.
  ///
  /// - Parameters:
  ///   - repository: The `Repository` providing the wrapped value.
  public convenience init(_ repository: Repository<R>) where R == T {
    self.init(repository) { $0 }
  }

  deinit {
    repository.removeObserver(self)
  }

  /// Triggers a sync in the `Repository`.
  public func sync() {
    Task {
      try await repository.sync()
    }
  }

  public func repository<DataType: Syncable>(_ repository: Repository<DataType>, dataDidChange data: DataType) {
    var newValue: T? = nil

    if let data = data as? R {
      newValue = map(data, currentValue)
    }

    value = newValue
  }

  public func repositoryDidFailToSyncData<DataType: Syncable>(_ repository: Repository<DataType>) {
    value = nil
  }
}
