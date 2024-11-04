import Foundation

/// An abstract class for a readonly `Repository`.
open class ReadonlyRepository<T: Syncable>: Repository<T> {

  /// Pulls the data downstream.
  ///
  /// This method implements how data is fetched from the datasource(s).
  ///
  /// - Returns: The resulting data.
  open func pull() async throws -> T {
    fatalError("<\(Self.self)> Subclass must override `pull()` without calling `super`")
  }

  /// Returns the data in memory. If unavailable, a sync will be performed and
  /// the resulting data returned upon completion.
  public func get() async throws -> T {
    let identifier = "GET-\(UUID().uuidString)"

    _log.debug("<\(Self.self):\(identifier)> Getting data...")

    switch await getState() {
    case .synced(let data),
        .notSynced(let data):
      _log.debug("<\(Self.self):\(identifier)> Getting data... OK: \(data)")

      return data
    case .initial:
      _log.debug("<\(Self.self):\(identifier)> Getting data... repository not synced, proceeding to auto sync")

      do {
        let data = try await sync(identifier: identifier)

        _log.debug("<\(Self.self):\(identifier)> Getting data... OK: \(data)")

        return data
      }
      catch {
        _log.error("<\(Self.self):\(identifier)> Getting data... ERR: \(error)")

        throw RepositoryError.invalidRead(cause: error)
      }
    }
  }

  override func createSyncTask(for state: RepositoryState<T>, identifier: String) -> Task<T, any Error> {
    Task {
      _log.debug("<\(Self.self):\(identifier)> Syncing downstream...")

      let subtask = Task { try await pull() }
      let result = await subtask.result

      guard !Task.isCancelled else {
        _log.debug("<\(Self.self):\(identifier)> Syncing downstream... CANCEL: Sync task has been overridden")

        throw CancellationError()
      }

      switch result {
      case .success(let data):
        _log.debug("<\(Self.self):\(identifier)> Syncing downstream... OK: \(data)")

        return data
      case .failure(let error):
        switch state {
        case .synced(let data):
          await setState(.notSynced(data))
        default:
          break
        }

        _log.error("<\(Self.self):\(identifier)> Syncing downstream... ERR: \(error)")

        throw RepositoryError.invalidSync(cause: error)
      }
    }
  }
}
