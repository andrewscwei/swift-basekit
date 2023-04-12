// © GHOZT

import Foundation

/// An abstract class for a read/write `Repository`.
open class ReadWriteRepository<T: Codable & Equatable>: Repository<T> {
  /// Specifies if the data stored in memory has changed since the last sync.
  private var isDirty: Bool = false

  /// Synchronously gets the value of `isDirty`.
  ///
  /// - Returns: The `isDirty` value.
  func getIsDirty() -> Bool { lockQueue.sync { isDirty } }

  /// Synchronously sets the value of `isDirty`.
  ///
  /// - Parameters:
  ///   - value: The value.
  func setIsDirty(_ value: Bool) {
    lockQueue.sync {
      isDirty = value
    }
  }

  /// Sets the data in memory, putting the repository in a dirty state. If
  /// `autoSync` is `true`, sync will follow immediately.
  ///
  /// - Parameters:
  ///   - value: The value to set.
  ///   - completion: Handler invoked upon completion.
  public func set(_ value: DataType, completion: @escaping (Result<DataType, Error>) -> Void = { _ in }) {
    setIsDirty(setCurrent(.synced(value)))

    if getIsDirty(), autoSync {
      log(.debug, isEnabled: self.debugMode) { "<\(Self.self)> Setting value to \"\(value)\"... OK: Proceeding to sync"}
      self.sync { result in
        switch result {
        case .failure(let error): completion(.failure(error))
        case .success: completion(.success(value))
        }
      }
    }
    else {
      log(.default, isEnabled: self.debugMode) { "<\(Self.self)> Setting value to \"\(value)\"... SKIP: No change"}
      completion(.success(value))
    }
  }

  /// Pushes the current data stored in memory to all data sources.
  ///
  /// - Parameters:
  ///   - current: The current value of the data.
  ///   - completion: Handler invoked upon completion.
  open func push(_ current: DataType, completion: @escaping (Result<DataType, Error>) -> Void = { _ in }) {
    fatalError("<\(Self.self)> Subclass must override `push(_:completion:)` without calling `super`.")
  }

  /// Synchronizes the data across all data sources according to the following
  /// conditions:
  ///   1. If the repository is not dirty (meaning that the data in memory has
  ///      not been changed externally), simply invoke a `pull`.
  ///   2. If the repository is dirty (data in memory has been changed
  ///      externally via `set`), invoke a `push`, consequently marking the
  ///      repository as no longer dirty.
  ///
  /// - Parameters:
  ///   - completion: Handler invoked upon completion.
  public override func sync(completion: @escaping (Result<DataType, Error>) -> Void = { _ in }) {
    if !getIsDirty() {
      syncDownstream(completion: completion)
    }
    else {
      syncUpstream(completion: completion)
    }
  }

  /// Synchronizes the data upstream (akin to a push).
  ///
  /// - Parameters:
  ///   - completion: Handler invoked upon completion.
  public func syncUpstream(completion: @escaping (Result<DataType, Error>) -> Void) {
    syncJob?.cancel()
    syncListeners.append(completion)

    let identifier = generateSyncIdentifier()

    let workItem = DispatchWorkItem { [weak self] in
      guard let current = self?.getCurrent() else { return }

      log(.debug, isEnabled: self?.debugMode == true) { "<\(Self.self)> Syncing upstream (id=\(identifier)) with value \"\(current)\"..." }

      switch current {
      case .notSynced:
        log(.error, isEnabled: self?.debugMode == true) { "<\(Self.self)> Syncing upstream (id=\(identifier)) with value \"\(current)\"... ERR: Nothing to sync" }
        self?.dispatchSyncResult(result: .failure(NSError(domain: "sh.ghozt.BaseKit.ReadWriteRepository", code: 0, userInfo: [
          NSLocalizedDescriptionKey: "Repository is not synced",
          NSLocalizedFailureErrorKey: "Repository is not synced"
        ])))
        return
      case .synced(let value):
        self?.push(value) { [weak self] result in
          switch result {
          case .failure(let error): log(.error, isEnabled: self?.debugMode == true) { "<\(Self.self)> Pushing value <\(value)> to data sources (id=\(identifier))...ERR: \(error)" }
          case .success: log(.debug, isEnabled: self?.debugMode == true) { "<\(Self.self)> Pushing value <\(value)> to data sources (id=\(identifier))... OK" }
          }

          self?.didSyncUpstream(identifier: identifier, result: result, completion: { [weak self] result in
            guard self?.isSyncing(identifier: identifier) == true else {
              log(.debug, isEnabled: self?.debugMode == true) { "<\(Self.self)> Syncing upstream (id=\(identifier)) with value \"\(current)\"... CANCEL: Operation cancelled, abandoning the current sync progress" }
              return
            }

            switch result {
            case .failure(let error): log(.error, isEnabled: self?.debugMode == true) { "<\(Self.self)> Syncing upstream (id=\(identifier)) with value \"\(current)\"... ERR: \(error)" }
            case .success(let data): log(.debug, isEnabled: self?.debugMode == true) { "<\(Self.self)> Syncing upstream (id=\(identifier)) with value \"\(current)\"... OK: \(data)" }
            }

            self?.dispatchSyncResult(result: result)
          })
        }
      }
    }

    syncJob = workItem
    syncIdentifier = identifier
    queue.async(execute: workItem)
  }

  override func didSyncDownstream(identifier: String, result: Result<DataType, Error>, completion: @escaping (Result<DataType, Error>) -> Void) {
    switch result {
    case .failure:
      setCurrent(.notSynced)
      completion(result)
    case .success(let value):
      if setCurrent(.synced(value)) {
        push(value) { [weak self] result in
          switch result {
          case .failure(let error): log(.error, isEnabled: self?.debugMode == true) { "<\(Self.self)> Pushing value \"\(value)\" to data sources... ERR: \(error)" }
          case .success: log(.debug, isEnabled: self?.debugMode == true) { "<\(Self.self)> Pushing value \"\(value)\" to data sources... OK" }
          }

          guard self?.isSyncing(identifier: identifier) == true else {
            log(.debug, isEnabled: self?.debugMode == true) { "<\(Self.self)> Syncing upstream (id=\(identifier))... CANCEL: Operation cancelled, abandoning the current sync progress" }
            return
          }

          completion(result)
        }
      }
      else {
        completion(result)
      }
    }
  }

  /// Handler invoked after an upstream sync. The `completion` block must be
  /// invoked to complete the sync process.
  ///
  /// - Parameters:
  ///   - identifier: The sync identifier.
  ///   - result: The synced result.
  ///   - completion: Handler invoked upon completion.
  func didSyncUpstream(identifier: String, result: Result<DataType, Error>, completion: @escaping (Result<T, Error>) -> Void) {
    setIsDirty(false)
    completion(result)
  }
}
