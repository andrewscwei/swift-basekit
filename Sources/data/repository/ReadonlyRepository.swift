import Foundation

/// A `Repository` type whos data is readonly.
public protocol ReadonlyRepository: Repository {

  /// Pulls the data downstream and returns it.
  ///
  /// This method implements how data is fetched from the datasource(s).
  func pull() async throws -> DataType
}

extension ReadonlyRepository {

  /// Returns the data in memory. If unavailable, a sync will be performed and
  /// the resulting data returned upon completion.
  ///
  /// - Returns: The data in memory.
  public func get() async throws -> DataType {
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

  func createSyncTask(for state: RepositoryState<DataType>, identifier: String) -> Task<DataType, any Error> {
    createDownstreamSyncTask(for: state, identifier: identifier)
  }

  func createDownstreamSyncTask(for state: RepositoryState<DataType>, identifier: String) -> Task<DataType, any Error> {
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
