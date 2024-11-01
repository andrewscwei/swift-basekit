import Foundation

/// A type of `LiveData` that wraps a value `T` as a result of a transformed
/// `Repository` value `R`.
public class RepositoryLiveData<T: Equatable, R: Codable & Equatable & Sendable>: LiveData<T>, RepositoryObserver {
  private let transform: (R, T?) -> T?

  let repository: Repository<R>

  /// Creates a new `RepositoryLiveData` instance and immediately assigns its
  /// wrapped value to a transformed `Repository` value. If the `Repository` is
  /// not synced, the initial wrapped value is `nil` and a sync will be invoked
  /// on the repository.
  ///
  /// Observers are notified every time the `Repository` value changes.
  ///
  /// - Parameters:
  ///   - repository: The `Repository`.
  ///   - transform: A block that transforms the current repository value into
  ///                the new wrapped value.
  public convenience init(_ repository: Repository<R>, transform: @escaping (R) -> T?) {
    self.init(repository) { value, _ in transform(value) }
  }

  /// Creates a new `RepositoryLiveData` instance and immediately assigns its
  /// wrapped value to a transformed `Repository` value. If the `Repository` is
  /// not synced, the initial wrapped value is `nil` and a sync will be invoked
  /// on the repository.
  ///
  /// Observers are notified every time the `Repository` value changes.
  ///
  /// - Parameters:
  ///   - repository: The `Repository`.
  ///   - transform: A block that transforms the current repository value and
  ///                wrapped value into the new wrapped value.
  public init(_ repository: Repository<R>, transform: @escaping (R, T?) -> T?) {
    self.repository = repository
    self.transform = transform

    super.init()

    repository.addObserver(self)

    Task {
      switch await repository.getState() {
      case .synced(let value), .notSynced(let value):
        currentValue = transform(value, currentValue)
      case .initial:
        currentValue = nil

        try await sync()
      }
    }
  }

  /// Creates a new `RepositoryLiveData` instance and immediately assigns its
  /// wrapped value to the `Repository` value. If the `Repository` is not
  /// synced, the wrapped value would be `nil` and a sync will be invoked where
  /// observers can anticipate the synced value upon the next change event.
  ///
  /// - Parameters:
  ///   - repository: The `Repository` to provide the wrapped value.
  public convenience init(_ repository: Repository<R>) where R == T {
    self.init(repository) { $0 }
  }

  deinit {
    repository.removeObserver(self)
  }

  /// Triggers a sync in the associated `Repository`.
  ///
  /// - Parameters:
  ///   - completion: Handler invoked when the `Repository` finishes synching.
  public func sync() async throws {
    try await repository.sync()
  }

  public func repository<DataType: Codable & Equatable>(_ repository: Repository<DataType>, dataDidChange data: DataType) {
    var newValue: T? = nil

    if let data = data as? R {
      newValue = transform(data, currentValue)
    }

    value = newValue
  }

  public func repositoryDidFailToSyncData<DataType: Codable & Equatable>(_ repository: Repository<DataType>) {
    value = nil
  }
}
