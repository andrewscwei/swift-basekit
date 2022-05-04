// © GHOZT

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
}
