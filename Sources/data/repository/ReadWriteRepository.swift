import Foundation

/// A `Repository` type whose data can be read and written to.
public protocol ReadWriteRepository: ReadonlyRepository {
  func push(_ data: DataType) async throws -> DataType
}

extension ReadWriteRepository {

  /// Sets the data in memory followed by an upstream sync.
  ///
  /// - Parameters:
  ///   - data: The data to set.
  @discardableResult
  public func set(_ newValue: DataType) async throws -> DataType {
    let identifier = "SET-\(UUID().uuidString)"

    _log.debug("<\(Self.self):\(identifier)> Setting data to \"\(newValue)\"...")

    if case .synced(let data) = await getState(), data == newValue {
      _log.debug("<\(Self.self):\(identifier)> Setting data to \"\(data)\"... SKIP: No change")

      return data
    }

    await setState(.notSynced(newValue))

    _log.debug("<\(Self.self):\(identifier)> Setting data to \"\(newValue)\"... proceeding to auto sync")

    do {
      let data = try await sync(identifier: identifier)

      _log.debug("<\(Self.self):\(identifier)> Setting data to \"\(newValue)\"... OK")

      return data
    }
    catch {
      _log.error("<\(Self.self):\(identifier)> Setting data to \"\(newValue)\"... ERR: \(error)")

      throw RepositoryError.invalidWrite(cause: error)
    }
  }


  /// Sets the data by patching the existing in memory.
  ///
  /// - Parameter mutate: Closure mutating the data.
  ///
  /// - Returns: The pathced data.
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
      return Task {
        _log.debug("<\(Self.self):\(identifier)> Syncing upstream...")

        let subtask = Task { try await push(data) }
        let result = await subtask.result

        guard !Task.isCancelled else {
          _log.debug("<\(Self.self):\(identifier)> Syncing upstream... CANCEL: Current sync has been overridden")

          throw CancellationError()
        }

        switch result {
        case .success(let newData):
          _log.debug("<\(Self.self):\(identifier)> Syncing upstream... OK: \(newData)")

          await setState(.synced(newData))

          return newData
        case .failure(let error):
          _log.error("<\(Self.self):\(identifier)> Syncing upstream... ERR: \(error)")

          throw RepositoryError.invalidSync(cause: error)
        }
      }
    default:
      return createDownstreamSyncTask(for: state, identifier: identifier)
    }
  }
}
