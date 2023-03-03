// © GHOZT

import Foundation

/// A disjoint union enum holding a value of one of two types, `L` or `R`.
public enum Either<L, R> {

  /// An `Either` holding a value of type `L`.
  case left(L)

  /// An `Either` holding a value of type `R`.
  case right(R)

  /// Indicates if this is a `.left`.
  public var isLeft: Bool {
    switch self {
    case .left: return true
    case .right: return false
    }
  }

  /// Indicates if this is a `.right`.
  public var isRight: Bool {
    switch self {
    case .left: return false
    case .right: return true
    }
  }

  /// Executes a block with the left value as its argument (if this is a
  /// `.left`) and returns the current `Either` to allow for method chaining. If
  /// this is a `.right`, the block will not be executed.
  ///
  /// - Parameters:
  ///   - execute: The block to execute with the left value as its argument.
  ///
  /// - Throws: Error thrown by the block.
  ///
  /// - Returns: The current `Either`.
  @discardableResult public func ifLeft(execute: (L) throws -> Void) rethrows -> Either<L, R> {
    switch self {
    case .left(let value): try execute(value)
    case .right: break
    }

    return self
  }

  /// Executes a block with the right value as its argument (if this is a
  /// `.right`) and returns the current `Either` to allow for function chaining.
  /// If this is a `.left`, the block will not be executed.
  ///
  /// - Parameters:
  ///   - execute: The block to execute with the right value as its argument.
  ///
  /// - Throws: Error thrown by the block.
  ///
  /// - Returns: The current `Either`.
  @discardableResult public func ifRight(execute: (R) throws -> Void) rethrows -> Either<L, R> {
    switch self {
    case .left: break
    case .right(let value): try execute(value)
    }

    return self
  }

  /// Returns a new `Either` with a new `L` value transformed by the given
  /// closure.
  ///
  /// - Parameters:
  ///   - transform: The block to execute to transform the current `L` value.
  ///
  /// - Throws: Error thrown by the transform closure.
  ///
  /// - Returns: The new `Either` with the transformed `L` value.
  public func mapLeft<T>(transform: (L) throws -> T) rethrows -> Either<T, R> {
    switch self {
    case .left(let value): return .left(try transform(value))
    case .right(let value): return .right(value)
    }
  }

  /// Returns a new `Either` with a new `R` value transformed by the given
  /// closure.
  ///
  /// - Parameters:
  ///   - transform: The block to execute to transform the current `R` value.
  ///
  /// - Throws: Error thrown by the transform closure.
  ///
  /// - Returns: The new `Either` with the transformed `R` value.
  public func mapRight<T>(transform: (R) throws -> T) rethrows -> Either<L, T> {
    switch self {
    case .left(let value): return .left(value)
    case .right(let value): return .right(try transform(value))
    }
  }

  /// Executes the first block if this is a `.left` or the second block if this
  /// is a `right`, each passing the associated contained value.
  ///
  /// - Parameters:
  ///   - executeL: The block to execute with the left value if this is a
  ///               `.left`.
  ///   - executeR: The block to execute with the right value if this is a
  ///               `.right`.
  ///
  /// - Throws: Error thrown by either block.
  ///
  /// - Returns: The return value of the executed block.
  @discardableResult public func fold(left: (L) throws -> Any, right: (R) throws -> Any) rethrows -> Any {
    switch self {
    case .left(let value): return try left(value)
    case .right(let value): return try right(value)
    }
  }
}

/// Extension to handle codable `L` and `R` values, which will be
/// encoded/decoded into a single value.
extension Either: Codable where L: Codable, R: Codable {

  enum CodingKeys: CodingKey {
    case left
    case right
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()

    switch self {
    case .left(let value):
      try container.encode(value)
    case .right(let value):
      try container.encode(value)
    }
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()

    do {
      let value = try container.decode(L.self)
      self = .left(value)
    }
    catch {
      let value = try container.decode(R.self)
      self = .right(value)
    }
  }
}
