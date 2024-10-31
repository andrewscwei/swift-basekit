import Foundation

/// An abstract class for a read-only `Repository`.
open class ReadOnlyRepository<T: Codable & Equatable & Sendable>: Repository<T> {
  /// Pulls the data downstream.
  ///
  /// This method implements how data is fetched from the data source(s).
  ///
  /// - Returns: The resulting data.
  open func pull() async throws -> T {
    throw RepositoryError.badImplementation(reason: "<\(Self.self)> Subclass must override `pull()` without calling `super`")
  }

  /// Returns the data in memory.
  ///
  /// If data has not been synced and `autoSync` is enabled, a sync will be
  /// attempted and the synced data returned upon completion.
  ///
  /// - Throws: If data is not available.
  public func get() async throws -> T {
    log(.debug, isEnabled: debugMode) { "<\(Self.self)> Getting data..."}

    switch getState() {
    case .synced(let data):
      log(.debug, isEnabled: debugMode) { "<\(Self.self)> Getting data... OK: \(data)"}

      return data
    case .notSynced:
      guard autoSync else {
        let error = error("Repository is not synced", domain: "BaseKit.Repository")

        log(.error, isEnabled: debugMode) { "<\(Self.self)> Getting data... ERR: \(error)"}

        throw RepositoryError.invalidRead(cause: error)
      }

      log(.debug, isEnabled: debugMode) { "<\(Self.self)> Getting data... repository not synced, proceeding to sync"}

      do {
        let data = try await sync()

        log(.debug, isEnabled: debugMode) { "<\(Self.self)> Getting data... OK: \(data)"}

        return data
      }
      catch {
        log(.error, isEnabled: debugMode) { "<\(Self.self)> Getting data... ERR: \(error)"}

        throw RepositoryError.invalidRead(cause: error)
      }
    }
  }

  override func createSyncTask() -> Task<T, any Error> {
    return Task {
      log(.debug, isEnabled: debugMode) { "<\(Self.self)> Syncing downstream..."}

      let result = await Task { try await pull() }.result

      do {
        try Task.checkCancellation()
      }
      catch {
        log(.debug, isEnabled: debugMode) { "<\(Self.self)> Syncing downstream... CANCEL: Current sync has been overridden"}

        throw error
      }

      switch result {
      case .success(let data):
        let isDirty = setState(.synced(data))

        if isDirty {
          log(.debug, isEnabled: debugMode) { "<\(Self.self)> Syncing downstream... OK: \(data)" }
        }
        else {
          log(.debug, isEnabled: debugMode) { "<\(Self.self)> Syncing downstream... SKIP: No changes" }
        }

        return data
      case .failure(let error):
        let _ = setState(.notSynced)

        log(.error, isEnabled: debugMode) { "<\(Self.self)> Syncing downstream... ERR: \(error)"}

        throw error
      }
    }
  }
}
