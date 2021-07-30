// © Sybl

import Foundation

/// Singleton dependency injection container.
public class DependencyInjectionContainer {

  public typealias Factory<T> = () -> T

  public static let `default` = DependencyInjectionContainer()

  private init() {}

  private var dependencies: [String: Any] = [:]

  /// Registers a dependency as a singleton with the container.
  ///
  /// - Parameters:
  ///   - type: The type of the dependency.
  ///   - component: The singleton instance of the dependency to provide when resolving.
  public func register<T>(_ type: T.Type, component: T) {
    let key = "\(type)"
    dependencies[key] = component

    log(.debug) { "Registering singleton dependency for \(key)... OK" }
  }

  /// Registers a dependency as a factory with the container.
  ///
  /// - Parameters:
  ///   - type: The type of the dependency.
  ///   - factory: The factory method.
  public func register<T>(_ type: T.Type, factory: @escaping Factory<T>) {
    let key = "\(type)"
    dependencies[key] = factory

    log(.debug) { "Registering factory dependency for \(key)... OK"}
  }

  /// Unregisters a dependency from the container.
  /// - Parameter type: The type of the dependency.
  public func unregister<T>(_ type: T.Type) {
    let key = "\(type)"
    dependencies.removeValue(forKey: key)
    log(.debug) { "Unregistering dependency for \(key)... OK" }
  }

  /// Resolves a dependency and returns an instance of the dependency depndending on how it was registered. If it was registered as a singleton, the same instance of the dependency will always be returned. If the it was registered as a factory, a new instance of the dependency will be returned. Note that this function expects that the dependency is already registered with the container, if not the app will terminate immediately.
  ///
  /// - Parameters:
  ///   - type: The type of the dependency.
  ///
  /// - Returns: An instance of the dependency.
  public func resolve<T>(_ type: T.Type = T.self) -> T {
    let key = "\(T.self)"
    var component: T?

    if let factory = dependencies[key] as? Factory<T> {
      component = factory()
    }
    else if let singleton = dependencies[key] as? T {
      component = singleton
    }

    precondition(component != nil, "No dependency found for type \(key)")

    log(.debug) { "Resolving dependency for \(key)... OK" }

    return component!
  }
}
