// © Sybl

import Foundation

extension Result {

  /// A successful `Result` with `Void` as its success value.
  public static var success: Result<Void, Failure> { .success(()) }

  /// Indicates if the current `Result` is a success.
  public var isSuccess: Bool {
    switch self {
    case .failure(_): return false
    case .success(_): return true
    }
  }

  /// Indicates if the current `Result` is a failure.
  public var isFailure: Bool {
    switch self {
    case .failure(_): return true
    case .success(_): return false
    }
  }

  /// The value of the current `Result` if this is a success, `nil` otherwise.
  public var value: Success? {
    switch self {
    case .failure(_): return nil
    case .success(let value): return value
    }
  }

  /// The error of the current `Result` if this is a failure, `nil` otherwise.
  public var error: Failure? {
    switch self {
    case .failure(let error): return error
    case .success(_): return nil
    }
  }

  /// Executes a block if this is a `.success`, then returns the current `Result` to allow for
  /// method chaining.
  ///
  /// - Parameter execute: The block to execute if this is a `.success`, with the success value as
  ///                      its argument.
  ///
  /// - Returns: The current `Result`.
  @discardableResult public func ifSuccess(execute: (Success) -> Void) -> Result<Success, Failure> {
    switch self {
    case .failure(_): break
    case .success(let value):
      execute(value)
    }
    return self
  }

  /// Executes a block if this is a `.failure`, then returns the current `Result` to allow for
  /// function chaining.
  ///
  /// - Parameter execute: The block to execute if this is a `.failure`, with the error as its
  ///                      argument.
  ///
  /// - Returns: The current `Result`.
  @discardableResult public func ifFailure(execute: (Failure) -> Void) -> Result<Success, Failure> {
    switch self {
    case .failure(let error): execute(error)
    case .success(_): break
    }

    return self
  }

  /// Executes a block if this is a `.success` with the current success value as its argument, then
  /// returns the new `Result` of the executed block. If this is a `.failure`, the current `Result`
  /// is returned immediately.
  ///
  /// - Parameter execute: The block to execute if this is a success, with the current success value
  ///                      as its argument.
  ///
  /// - Returns: The new `Result` if this is a `.success` or the current `Result` if this is a
  ///            `.failure`.
  @discardableResult public func then<R>(execute: (Success) -> Result<R, Failure>) -> Result<R, Failure> {
    switch self {
    case .failure(let error): return .failure(error)
    case .success(let value): return execute(value)
    }
  }

  /// Executes a block if this is a `.failure` with the current error as its argument, then returns
  /// the new `Result` of the executed block. If this is a `.success`, the current `Result` is
  /// returned immediately.
  ///
  /// - Parameter execute: The block to execute if this is a failure.
  ///
  /// - Returns: The new `Result` if this is a `.failure` or the current `Result` if this is a
  ///            `.success`.
  @discardableResult public func handle<R: Error>(execute: (Failure) -> Result<Success, R>) -> Result<Success, R> {
    switch self {
    case .failure(let error): return execute(error)
    case .success(let value): return .success(value)
    }
  }

  /// Returns a copy of the current `Result` removing the success value.
  ///
  /// - Returns: The new `Result`.
  public func withOmittedValue() -> Result<Void, Failure> {
    switch self {
    case .success(_): return .success
    case .failure(let error): return .failure(error)
    }
  }

  /// Returns a copy of the current `Result` replacing the success value with `nil`.
  ///
  /// - Returns: The new `Result`.
  public func withNilValue<T>() -> Result<T?, Failure> {
    switch self {
    case .success(_): return .success(nil)
    case .failure(let error): return .failure(error)
    }
  }

  /// Returns a copy of the current `Result` replacing the success value with a new value.
  ///
  /// - Parameter newValue: The new value.
  ///
  /// - Returns: The new `Result`.
  public func withReplacedValue<T>(_ newValue: T) -> Result<T, Failure> {
    switch self {
    case .success(_): return .success(newValue)
    case .failure(let error): return .failure(error)
    }
  }

  /// Returns a copy of the current `Result` with the success value type modified to become
  /// optional.
  ///
  /// - Returns: The new `Result`.
  public func withOptionalValue() -> Result<Success?, Failure> {
    switch self {
    case .success(let value): return .success(value as Success?)
    case .failure(let error): return .failure(error)
    }
  }

  /// Returns a copy of the current `Result` with the failure value upcasted to the generic `Error`
  /// type.
  ///
  /// - Returns: The new `Result`.
  public func withUpcastedFailure() -> Result<Success, Error> {
    switch self {
    case .success(let value): return .success(value)
    case .failure(let error): return .failure(error as Error)
    }
  }
}
