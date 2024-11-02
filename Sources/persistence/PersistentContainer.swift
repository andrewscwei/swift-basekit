import CoreData
import Foundation

public final class PersistentContainer {

  let groupIdentifier: String
  let modelName: String

  /// Returns the `NSManagedObjectContext` for the application (which is already
  /// bound to the persistent store coordinator for the application). This
  /// property could be optional (though not ideal) since there are legitimate
  /// error conditions that could cause the creation of the context to fail.
  private lazy var context: NSManagedObjectContext = {
    var context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    context.persistentStoreCoordinator = coordinator

    return context
  }()

  /// The `NSPersistentStoreCoordinator` for the application. This lazy property
  /// creates and returns a coordinator, having added the store for the
  /// application to it. This property could be optional (though not ideal)
  /// since there are legitimate error conditions that could cause the creation
  /// of the store to fail.
  private lazy var coordinator: NSPersistentStoreCoordinator = {
    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)

    do {
      try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: [
        NSInferMappingModelAutomaticallyOption: true,
        NSMigratePersistentStoresAutomaticallyOption: true,
      ])

      _log.info("Initializing Core Data for group identifier <\(groupIdentifier)> and model name <\(modelName)>... OK")
    }
    catch {
      _log.error("Initializing Core Data for group identifier <\(groupIdentifier)> and model name <\(modelName)>... ERR: \(error)")
    }

    return coordinator
  }()

  /// `URL` to the `CoreData` SQLite file.
  private lazy var storeURL: URL? = {
    FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)?.appendingPathComponent("\(modelName).sqlite+")
  }()

  /// `URL` to the `CoreData` model file.
  private lazy var modelURL: URL? = {
    Bundle.main.url(forResource: modelName, withExtension: "momd")
  }()

  /// The `NSManagedObjectModel` for the application.
  private lazy var model: NSManagedObjectModel = {
    guard let modelURL = modelURL else {
      _log.fault("Loading Core Data model... ERR: Unable to evaluate file URL of Core Data model")
      abort()
    }

    guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
      _log.fault("Loading Core Data model... ERR: Unable to create Core Data model at URL \(modelURL)")
      abort()
    }

    return model
  }()

  /// Executes the `block` in the `NSManagedObjectContext`'s private queue.
  ///
  /// - Parameter block: The `block` to execute.
  @discardableResult
  public func perform<T>(block: @escaping (_ context: NSManagedObjectContext, _ coordinator: NSPersistentStoreCoordinator) throws -> T) async throws -> T {
    try await context.perform { [self] in
      try block(context, coordinator)
    }
  }

  public init(modelName: String, groupIdentifier: String) {
    self.modelName = modelName
    self.groupIdentifier = groupIdentifier
  }
}
