// © Sybl

import Foundation

extension Result {

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

  /// Executes a block if this is a success, then returns the current `Result` for chainability.
  ///
  /// - Parameter execute: The block to execute if this is a success.
  ///
  /// - Returns: The current `Result`.
  public func ifSuccess(execute: (Success) -> Void) -> Result<Success, Failure> {
    switch self {
    case .failure(_): break
    case .success(let value):
      execute(value)
    }
    return self
  }

  /// Executes a block if this is a failure, then returns the current `Result` for chainability.
  ///
  /// - Parameter execute: The block to execute if this is a failure.
  ///
  /// - Returns: The current `Result`.
  public func ifFailure(execute: (Failure) -> Void) -> Result<Success, Failure> {
    switch self {
    case .failure(let error): execute(error)
    case .success(_): break
    }

    return self
  }

  /// Executes a block if this is a success where a new type of `Result` can be derived from the current `Result`. If this is a failure, the current `Result` is returned immediately.
  ///
  /// - Parameter execute: The block to execute if this is a success.
  ///
  /// - Returns: The new `Result`.
  public func then<R>(execute: (Success) -> Result<R, Failure>) -> Result<R, Failure> {
    switch self {
    case .failure(let error): return .failure(error)
    case .success(let value): return execute(value)
    }
  }

  /// Executes a block if this is a failure where a new type of `Result` can be derived from the current `Result`. If this is a success, the current `Result` is returned immediately.
  ///
  /// - Parameter execute: The block to execute if this is a failure.
  ///
  /// - Returns: The new `Result`.
  public func handle<R: Error>(execute: (Failure) -> Result<Success, R>) -> Result<Success, R> {
    switch self {
    case .failure(let error): return execute(error)
    case .success(let value): return .success(value)
    }
  }
}
