import Foundation

/// A data holder that wraps some value of type `T` and notifies observers
/// whenever the value changes. The wrapped value can be `nil`, indicating the
/// absence of a value, which is also the default value.
///
/// The wrapped value is read-only and cannot be modified. See `MutableLiveData`
/// for the mutable version of `LiveData`.
public class LiveData<T: Equatable>: CustomStringConvertible {
  public typealias Listener = (T?) -> Void

  public var debug: Bool = false

  let lockQueue: DispatchQueue = DispatchQueue(label: "BaseKit.LiveData<\(T.self)>", qos: .utility)
  var listeners: [AnyHashable: Listener] = [:]
  var currentValue: T?

  public internal(set) var value: T? {
    get {
      return lockQueue.sync { currentValue }
    }

    set {
      guard value != newValue else { return }

      lockQueue.sync { currentValue = newValue }
      log(.debug, isEnabled: debug) { "[LiveData<\(T.self)>] Updating value... OK: \(newValue.map { "\($0)" } ?? "nil")" }
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

  /// Creates a new `LiveData` instance and executes an asynchronous method that
  /// eventually yields an initial value.
  ///
  /// Registered observers will be notified once the initial value is assigned.
  ///
  /// - Parameters:
  ///   - getValue: The asynchronous block to execute.
  public init(_ getValue: (@escaping (T) -> Void) -> Void) {
    currentValue = nil

    getValue { self.value = $0 }
  }

  /// Creates a new `LiveData` instance and executes an asynchronous method that
  /// eventually yields an initial value.
  ///
  /// Registered observers will be notified once the initial value is assigned.
  ///
  /// - Parameters:
  ///   - getValue: The asynchronous block to execute.
  public init(_ getValue: (@escaping (T) -> Void) throws -> Void) {
    currentValue = nil

    try? getValue { self.value = $0 }
  }

  /// Creates a new `LiveData` instance and executes an asynchronous method that
  /// eventually yields an initial wrapped value.
  ///
  /// Registered observers will be notified once the initial value is assigned.
  ///
  /// - Parameters:
  ///   - getValue: The asynchronous block to execute.
  public init(_ getValue: @escaping () async -> T) {
    currentValue = nil

    Task.detached {
      self.value = await getValue()
    }
  }

  /// Creates a new `LiveData` instance and executes an asynchronous method that
  /// eventually yields an initial wrapped value.
  ///
  /// Registered observers will be notified once the initial value is assigned.
  ///
  /// - Parameters:
  ///   - getValue: The asynchronous block to execute.
  public init(_ getValue: @escaping () async throws -> T) {
    currentValue = nil

    Task.detached {
      self.value = try? await getValue()
    }
  }

  /// Creates a new `LiveData` instance and executes an asynchronous method that
  /// eventually yields an initial value represented by the success value of a
  /// `Result` object.
  ///
  /// Registered observers will be notified once the initial value is assigned.
  ///
  /// - Parameters:
  ///   - getValue: The asynchronous block to execute.
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

  /// Emits the current wrapped value to all observers.
  public func emit() {
    let listeners = lockQueue.sync { self.listeners }

    for (_, listener) in listeners {
      listener(value)
    }
  }

  /// Resets the wrapped value to `nil`.
  public func reset() {
    value = nil
  }

  /// Registers an observer to notify when changes occur in the wrapped value.
  /// Registering an already registered observer will overwrite the previous
  /// `listener`.
  ///
  /// - Parameters:
  ///   - observer: The object to register as an observer of this `LiveData`.
  ///   - listener: The block to execute when the wrapped data is updated. It is
  ///               best to use `weak self` within the block.
  public func observe(for observer: AnyObject, listener: @escaping Listener) {
    lockQueue.sync {
      let identifier = ObjectIdentifier(observer)
      guard !listeners.keys.contains(identifier) else { return }
      listeners[identifier] = listener
    }
  }

  /// Unregisters an observer. If the observer was never registered, nothing
  /// happens.
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
