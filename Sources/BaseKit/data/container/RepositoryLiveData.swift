// © GHOZT

import Foundation

/// A type of `LiveData` that wraps the transformed value `T` of a `Repository`
/// value `R`.
public class RepositoryLiveData<T: Equatable, R: Codable & Equatable>: LiveData<T>, RepositoryObserver {
  private let transform: (R) -> T

  let repository: Repository<R>

  /// Creates a new `RepositoryLiveData` instance and immediately assigns its
  /// wrapped value to a transformed `Repository` value. If the `Repository`
  /// is not synced, the wrapped value would be `nil` and a sync will be invoked
  /// which observers can expect the synced value upon the next change event.
  ///
  /// - Parameters:
  ///   - repository: The `Repository`.
  ///   - transform: A block that transforms the repository value to the wrapped
  ///                value.
  public init(_ repository: Repository<R>, transform: @escaping (R) -> T) {
    self.repository = repository
    self.transform = transform

    super.init()

    repository.addObserver(self)

    switch repository.getCurrent() {
    case .synced(let value):
      currentValue = transform(value)
    case .notSynced:
      currentValue = nil
      sync()
    }
  }

  /// Creates a new `RepositoryLiveData` instance and immediately
  /// assigns its wrapped value to the `Repository` value. If the `Repository`
  /// is not synced, the wrapped value would be `nil` and a sync will be invoked
  /// where observers can anticipate the synced value upon the next change
  /// event.
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
  public func sync(completion: @escaping (Result<Void, Error>) -> Void = { _ in }) {
    repository.sync { completion($0.map { _ in () }) }
  }

  public func repository<DataType: Codable & Equatable>(_ repository: Repository<DataType>, dataDidChange data: DataType) {
    var newValue: T? = nil

    if let data = data as? R {
      newValue = transform(data)
    }

    value = newValue
  }

  public func repositoryDidFailToSyncData<DataType: Codable & Equatable>(_ repository: Repository<DataType>) {
    value = nil
  }
}
