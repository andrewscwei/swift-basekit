// © Sybl

import Foundation

/// Injects the dependency into the associated property.
@propertyWrapper
public struct Inject<T> {

  private var value: T?

  public var wrappedValue: T {
    get { value ?? DependencyInjectionContainer.default.resolve() }
    set { value = newValue }
  }

  public init() {}
}
