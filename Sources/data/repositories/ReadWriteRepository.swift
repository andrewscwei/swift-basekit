import Foundation

/// A `Repository` type whose data can be read and written.
public protocol ReadWriteRepository: ReadOnlyRepository {

  /// Pushes the data to any data source(s).
  ///
  /// - Parameters:
  ///   - data: The data to push.
  /// - Returns: The pushed data.
  /// - Throws: If push fails.
  func push(_ data: DataType) async throws -> DataType
}

extension ReadWriteRepository {

  /// Sets the data in memory and synchronizes the result with data source(s).
  ///
  /// - Parameters:
  ///   - data: The data to set.
  /// - Returns: The data set.
  /// - Throws: When synchronization fails.
  @discardableResult
  public func set(_ newData: DataType) async throws -> DataType {
    let identifier = "SET-\(UUID().uuidString)"
    let state = await getState()

    if case .synced(let data) = state, data == newData {
      return data
    }

    await setState(.notSynced(newData))

    _log.debug { "[\(Self.self):\(identifier)] Setting data... OK: Proceeding to auto sync\n↘︎ data=\(newData)" }

    return try await sync(identifier: identifier)
  }

  /// Patches the data in memory and synchronizes the result with data
  /// source(s).
  ///
  /// - Parameters:
  ///   - mutate: Closure mutating the data.
  /// - Returns: The patched data.
  /// - Throws: If the repository has not been synced yet or if the follow-up
  ///           synchronization fails.
  @discardableResult
  public func patch(mutate: (inout DataType) -> DataType) async throws -> DataType {
    let state = await getState()

    switch state {
    case .initial:
      throw RepositoryError.invalidWrite(cause: error("Unable to patch an unsynced repository"))
    case .notSynced(let data),
        .synced(let data):
      var mutableData = data
      let mutatedData = mutate(&mutableData)

      return try await set(mutatedData)
    }
  }

  public func createSyncTask(for state: RepositoryState<DataType>, identifier: String) -> Task<DataType, any Error> {
    switch state {
    case .notSynced(let data):
      return createUpstreamSyncTask(data: data, for: state, identifier: identifier)
    default:
      return createDownstreamSyncTask(for: state, identifier: identifier)
    }
  }

  func createUpstreamSyncTask(data: DataType, for state: RepositoryState<DataType>, identifier: String) -> Task<DataType, any Error> {
    Task {
      _log.debug { "[\(Self.self):\(identifier)] Syncing upstream..." }

      let subtask = Task { try await push(data) }
      let result = await subtask.result

      guard !Task.isCancelled else {
        _log.debug { "[\(Self.self):\(identifier)] Syncing upstream... CANCEL: Sync task has been overridden" }

        throw CancellationError()
      }

      switch result {
      case .success(let newData):
        _log.debug { "[\(Self.self):\(identifier)] Syncing upstream... OK\n↘︎ data=\(newData)" }

//        await setState(.synced(newData))

        return newData
      case .failure(let error):
        _log.error { "[\(Self.self):\(identifier)] Syncing upstream... ERR\n↘︎ error=\(error)" }

        throw error
      }
    }
  }
}
