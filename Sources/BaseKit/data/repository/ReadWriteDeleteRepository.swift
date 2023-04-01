// © GHOZT

import Foundation

/// An abstract class for a read/write/delete `Repository`.
open class ReadWriteDeleteRepository<T: Codable & Equatable>: ReadWriteRepository<T?> {
  override func emit() {
    let value = getCurrent()

    notifyObservers { observer in
      switch value {
      case .notSynced:
        observer.repositoryDidFailToSyncData(self)
      case .synced(let value):
        if let value = value {
          observer.repository(self, dataDidChange: value)
        }
        else {
          observer.repository(self, dataDidChange: nil)
        }
      }
    }
  }

  /// Deletes the current value from the repository and triggers a sync if
  /// `autoSync` is enabled.
  ///
  /// - Parameters:
  ///   - completion: Handler invoked upon completion. If there is nothing  to
  ///                 delete, the `Result` is still a `.success`.
  public func delete(completion: @escaping (Result<Void, Error>) -> Void = { _ in }) {
    if case .synced(let value) = getCurrent(), value == nil {
      // Nothing happens if deleting an already deleted value.
      completion(.success(()))
    }
    else {
      setIsDirty(setCurrent(.synced(nil)))

      if autoSync {
        log(.debug, isEnabled: debugMode) { "[\(Self.self)] Deleting value... OK: Proceeding to sync"}

        sync { result in
          switch result {
          case .success: completion(.success(()))
          case .failure(let error): completion(.failure(error))
          }
        }
      }
      else {
        completion(.success)
      }
    }
  }
}
