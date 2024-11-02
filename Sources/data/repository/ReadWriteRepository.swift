import Foundation

/// An abstract class for a read/write `Repository`.
open class ReadWriteRepository<T: Codable & Equatable & Sendable>: ReadOnlyRepository<T> {
  private var isDirty: Bool = false

  /// Pushes the data upstream.
  ///
  /// This method implements how data is pushed to the data source(s).
  ///
  /// - Parameters:
  ///   - data: The data to push.
  open func push(_ data: T) async throws -> T {
    fatalError("<\(Self.self)> Subclass must override `push(_:)` without calling `super`")
  }

  /// Sets the data in memory. If `autoSync` is `true`, an upstream sync will
  /// follow immediately.
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

    if autoSync {
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
    else {
      _log.debug("<\(Self.self):\(identifier)> Setting data to \"\(newValue)\"... OK")

      return newValue
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
