import Foundation

/// A wrapper for a value of type `T` that notifies observers of changes. The
/// value can be `nil` (default). The value is readonly; for a mutable version,
/// use `MutableLiveData`.
public class LiveData<T: Equatable>: CustomStringConvertible, @unchecked Sendable {
  public typealias Listener = (T?) -> Void

  let lockQueue: DispatchQueue = DispatchQueue(label: "BaseKit.LiveData", qos: .utility)
  var listeners: [AnyHashable: Listener] = [:]
  var currentValue: T?

  public internal(set) var value: T? {
    get { lockQueue.sync { currentValue } }

    set {
      guard value != newValue else { return }

      lockQueue.sync { currentValue = newValue }
      _log.debug("[LiveData<\(T.self)>] Updating value... OK: \(newValue.map { "\($0)" } ?? "nil")")
      emit()
    }
  }

  /// Creates a new `LiveData` instance with an initial value.
  ///
  /// - Parameters:
  ///   - value: The initial wrapped value.
  public init(_ value: T? = nil) {
    currentValue = value
  }

  /// Creates a `LiveData` instance and runs an async closure to provide an
  /// initial value.
  ///
  /// Observers are notified when the initial value is set.
  ///
  /// - Parameters:
  ///   - getValue: The async closure.
  public init(_ getValue: sending @escaping () async -> T) {
    currentValue = nil

    Task {
      self.value = await getValue()
    }
  }

  /// Creates a `LiveData` instance and runs a throwable async closure to
  /// provide an initial value.
  ///
  /// Observers are notified when the initial value is set.
  ///
  /// - Parameters:
  ///   - getValue: The async closure.
  public init(_ getValue: sending @escaping () async throws -> T) {
    currentValue = nil

    Task {
      self.value = try? await getValue()
    }
  }

  /// Creates a `LiveData` instance and runs an async closure to provide an
  /// initial value.
  ///
  /// Observers are notified when the initial value is set.
  ///
  /// - Parameters:
  ///   - getValue: The async closure.
  public init(_ getValue: (@escaping (T) -> Void) -> Void) {
    currentValue = nil

    getValue { self.value = $0 }
  }

  /// Creates a `LiveData` instance and runs a throwable async closure to
  /// provide an initial value.
  ///
  /// Observers are notified when the initial value is set.
  ///
  /// - Parameters:
  ///   - getValue: The async closure.
  public init(_ getValue: (@escaping (T) -> Void) throws -> Void) {
    currentValue = nil

    try? getValue { self.value = $0 }
  }

  /// Creates a `LiveData` instance and runs an async closure to provide an
  /// initial value.
  ///
  /// Observers are notified when the initial value is set.
  ///
  /// - Parameters:
  ///   - getValue: The aync closure to execute.
  public init(_ getValue: (@escaping (Result<T, Error>) -> Void) -> Void) {
    currentValue = nil

    getValue { result in
      switch result {
      case .failure:
        break
      case .success(let value):
        self.value = value
      }
    }
  }

  /// Emits the current value to observers.
  public func emit() {
    let listeners = lockQueue.sync { self.listeners }

    for (_, listener) in listeners {
      listener(value)
    }
  }

  /// Resets the current value to `nil`.
  public func reset() {
    value = nil
  }

  /// Registers an observer for value changes, overwriting any existing listener
  /// if already registered.
  ///
  /// - Parameters:
  ///   - observer: The observer to register.
  ///   - listener: The listener closure to invoke upon value changes.
  public func observe(for observer: AnyObject, listener: @escaping Listener) {
    lockQueue.sync {
      let identifier = ObjectIdentifier(observer)
      guard !listeners.keys.contains(identifier) else { return }
      listeners[identifier] = listener
    }
  }

  /// Unregisters an observer; does nothing if the observer wasn’t registered.
  ///
  /// - Parameters:
  ///   - observer: The observer to unregister.
  public func unobserve(for observer: AnyObject) {
    lockQueue.sync {
      let identifier = ObjectIdentifier(observer)
      listeners.removeValue(forKey: identifier)
    }
  }

  public var description: String {
    if let value = value {
      return "LiveData<\(T.self)<\(value)>>"
    }
    else {
      return "LiveData<\(T.self)<nil>>"
    }
  }
}
