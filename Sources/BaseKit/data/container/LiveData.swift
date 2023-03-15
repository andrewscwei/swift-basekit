// © GHOZT

import Foundation

/// A data holder class that wraps some data `T` and notifies its observers
/// whenever the value of the wrapped data changes.
///
/// Observers can be registered and unregistered via `observe(for:listener:)`
/// and `unobserve(for:)`, respectively. Observers will only be notified if the
/// value of the wrapped data changes (i.e. assigning the same value to the
/// wrapped data will not notify observers).
///
/// The value of the wrapped data cannot be modified via this class. For its
/// mutable counterpart, see `MutableLiveData`.
public class LiveData<T: Equatable>: CustomStringConvertible {
  public typealias Listener = (T?) -> Void

  let lockQueue: DispatchQueue = DispatchQueue(label: "sh.ghozt.arckit.LiveData<\(T.self)>", qos: .utility)
  private var listeners: [AnyHashable: Listener] = [:]
  var currentValue: T?

  public internal(set) var value: T? {
    get {
      return lockQueue.sync { currentValue }
    }

    set {
      guard value != newValue else { return }
      lockQueue.sync { currentValue = newValue }
      emit()
    }
  }

  /// Creates a new `LiveData` instance with the specified value to wrap.
  ///
  /// - Parameters:
  ///   - value: The value of the wrapped data.
  public init(_ value: T? = nil) {
    currentValue = value
  }

  /// Creates a new `LiveData` instance and executes an asynchronous method that
  /// eventually yields the wrapped value. Consequently, the new value will be
  /// emitted to all observers.
  ///
  /// - Parameters:
  ///   - getValue: The asynchronous block to execute.
  public init(_ getValue: (@escaping (T) -> Void) -> Void) {
    currentValue = nil

    getValue { self.value = $0 }
  }

  /// Creates a new `LiveData` instance and executes an asynchronous method that
  /// eventually yields the wrapped value in a `Result` object. Consequently,
  /// the new value will be emitted to all observers.
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

  /// Emits the wrapped value to all observers.
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

  /// Begins observing changes in the wrapped value. `listener` will be invoked
  /// every time the value is modified. If the observer is already observing
  /// this `LiveData`, the previous `listener` will be overwritten by this one.
  ///
  /// - Parameters:
  ///   - observer: The object observing this `LiveData`.
  ///   - listener: The block to execute when the wrapped value is modified. It
  ///               is best to use `weak self` within the block.
  public func observe(for observer: AnyObject, listener: @escaping Listener) {
    lockQueue.sync {
      let identifier = ObjectIdentifier(observer)
      guard !listeners.keys.contains(identifier) else { return }
      listeners[identifier] = listener
    }
  }

  /// Stops observing changes in the wrapped value for the specified object
  /// (a.k.a. the observer). Nothing happens if the object was never an observer
  /// of this `LiveData`.
  ///
  /// - Parameters:
  ///   - observer: The object observing this `LiveData`.
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
