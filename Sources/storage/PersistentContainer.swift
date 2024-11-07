import CoreData

public final class PersistentContainer: @unchecked Sendable {
  public enum Error: Swift.Error {
    case noStoreCoordinator
  }

  private let context: NSManagedObjectContext

  /// Creates a new `PersistenceContainer` instance.
  ///
  /// - Parameters:
  ///   - modelName: The model name.
  ///   - groupIdentifier: The group identifier.
  public init(modelName: String, groupIdentifier: String) {
    context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)

    if let coordinator = Self.createCoordinator(modelName: modelName, groupIdentifier: groupIdentifier) {
      context.persistentStoreCoordinator = coordinator
    }
  }

  /// Executes the `block` in the `NSManagedObjectContext`'s private queue and
  /// returns some resulting data.
  ///
  /// - Parameters:
  ///   - block: The closure to execute.
  /// - Returns: The resulting data.
  /// - Throws: If persistent store coordinator is invalid or if the block
  ///           threw.
  public func perform<T>(block: @escaping (NSManagedObjectContext) throws -> T) async throws -> T {
    guard context.persistentStoreCoordinator != nil else { throw Error.noStoreCoordinator }

    return try await context.perform {
      try block(self.context)
    }
  }

  private static func createCoordinator(modelName: String, groupIdentifier: String) -> NSPersistentStoreCoordinator? {
    guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd"), let model = NSManagedObjectModel(contentsOf: modelURL) else {
      _log.fault { "Loading Core Data model with name \(modelName)... ERR: Unable to create Core Data model at URL" }

      return nil
    }

    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)

    if let storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)?.appendingPathComponent("\(modelName).sqlite+") {
      do {
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: [
          NSInferMappingModelAutomaticallyOption: true,
          NSMigratePersistentStoresAutomaticallyOption: true,
        ])

        _log.info { "Initializing Core Data for group identifier <\(groupIdentifier)> and model name <\(modelName)>... OK" }
      }
      catch {
        _log.error { "Initializing Core Data for group identifier <\(groupIdentifier)> and model name <\(modelName)>... ERR: \(error)" }
      }
    }

    return coordinator
  }
}
