import Foundation

/// An abstract class for a read/write `Repository`.
open class ReadWriteRepository<T: Syncable>: ReadonlyRepository<T> {
  private var isDirty: Bool = false

  /// Pushes the data upstream.
  ///
  /// This method implements how data is pushed to the datasource(s).
  ///
  /// - Parameters:
  ///   - data: The data to push.
  open func push(_ data: T) async throws -> T {
    fatalError("<\(Self.self)> Subclass must override `push(_:)` without calling `super`")
  }

  /// Sets the data in memory followed by an upstream sync.
  ///
  /// - Parameters:
  ///   - data: The data to set.
  @discardableResult
  public func set(_ newValue: T) async throws -> T {
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
  public func patch(mutate: (inout T) -> T) async throws -> T {
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

  override func createSyncTask(for state: RepositoryState<T>, identifier: String) -> Task<T, any Error> {
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
      return super.createSyncTask(for: state, identifier: identifier)
    }
  }
}
