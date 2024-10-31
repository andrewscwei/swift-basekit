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
    throw RepositoryError.badImplementation(reason: "<\(Self.self)> Subclass must override `push(_:)` without calling `super`")
  }

  /// Sets the data in memory. If `autoSync` is `true`, an upstream sync will
  /// follow immediately.
  ///
  /// - Parameters:
  ///   - data: The data to set.
  @discardableResult public func set(_ data: T) async throws -> T {
    log(.debug, isEnabled: self.debugMode) { "<\(Self.self)> Setting data to \"\(data)\"..."}

    let isDirty = setState(.synced(data))

    setIsDirty(isDirty)

    if isDirty {
      guard autoSync else {
        log(.debug, isEnabled: self.debugMode) { "<\(Self.self)> Setting data to \"\(data)\"... OK"}

        return data
      }

      log(.debug, isEnabled: self.debugMode) { "<\(Self.self)> Setting data to \"\(data)\"... proceeding to sync"}

      do {
        let data = try await sync()

        log(.debug, isEnabled: debugMode) { "<\(Self.self)> Setting data to \"\(data)\"... OK"}

        return data
      }
      catch {
        log(.error, isEnabled: debugMode) { "<\(Self.self)> Setting data to \"\(data)\"... ERR: \(error)"}

        throw RepositoryError.invalidWrite(cause: error)
      }
    }
    else {
      log(.debug, isEnabled: self.debugMode) { "<\(Self.self)> Setting data to \"\(data)\"... SKIP: No change"}

      return data
    }
  }

  private func setIsDirty(_ value: Bool) { lockQueue.sync { isDirty = value } }

  private func getIsDirty() -> Bool { lockQueue.sync { isDirty } }

  override func createSyncTask() -> Task<T, any Error> {
    guard getIsDirty() else { return super.createSyncTask() }

    return Task {
      log(.debug, isEnabled: debugMode) { "<\(Self.self)> Syncing upstream..." }

      switch getState() {
      case .notSynced:
        log(.error, isEnabled: debugMode) { "<\(Self.self)> Syncing upstream... ERR: Nothing to sync" }

        throw error("Repository is not synced", domain: "BaseKit.Repository")
      case .synced(let data):
        let result = await Task { try await push(data) }.result

        do {
          try Task.checkCancellation()
        }
        catch {
          log(.debug, isEnabled: debugMode) { "<\(Self.self)> Syncing upstream... CANCEL: Current sync has been overridden" }

          throw error
        }

        switch result {
        case .success(let newData):
          log(.debug, isEnabled: debugMode) { "<\(Self.self)> Syncing upstream... OK: \(newData)" }

          setIsDirty(false)

          return newData
        case .failure(let error):
          log(.error, isEnabled: debugMode) { "<\(Self.self)> Syncing upstream... ERR: \(error)" }

          throw error
        }
      }
    }
  }
}
