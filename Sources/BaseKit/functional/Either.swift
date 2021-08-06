// © Sybl

import Foundation

/// A disjoint union holding a value of one of two types, `L` or `R`.
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

  /// Returns the value if this is a `.left`, `nil` otherwise.
  public var leftValue: L? {
    switch self {
    case .left(let value): return value
    case .right: return nil
    }
  }

  /// Returns the value if this is a `.right`, `nil` otherwise.
  public var rightValue: R? {
    switch self {
    case .left: return nil
    case .right(let value): return value
    }
  }

  /// Executes the provided block with the left value as its argument if this is a `.left`, and finally returns this
  /// `Either` instance.
  ///
  /// - Parameter execute: The block to execute with the left value as its argument.
  ///
  /// - Returns: This `Either` instance.
  public func ifLeft(execute: (L) -> Void) -> Either<L, R> {
    switch self {
    case .left(let value): execute(value)
    case .right: break
    }

    return self
  }

  /// Executes the provided block with the right value as its argument if this is a `.right`, and finally returns this
  /// `Either` instance.
  ///
  /// - Parameter execute: The block to execute with the right value as its argument.
  ///
  /// - Returns: This `Either` instance.
  public func ifRight(execute: (R) -> Void) -> Either<L, R> {
    switch self {
    case .left: break
    case .right(let value): execute(value)
    }

    return self
  }

  /// Executes the first block if this is a `.left` or the second block if this is a `right`, each passing the
  /// corresponding containing value.
  ///
  /// - Parameters:
  ///   - executeL: The block to execute with the left value if this is a `.left`.
  ///   - executeR: The block to execute with the right value if this is a `.right`.
  ///
  /// - Returns: The return value of the executed block.
  public func fold(executeL: (L) -> Any, executeR: (R) -> Any) -> Any {
    switch self {
    case .left(let value): return executeL(value)
    case .right(let value): return executeR(value)
    }
  }
}

/// Extension to handle codable left and right values.
extension Either: Codable where L: Codable, R: Codable {

  enum CodingKeys: CodingKey {
    case left
    case right
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    switch self {
    case .left(let value):
      try container.encode(value, forKey: .left)
    case .right(let value):
      try container.encode(value, forKey: .right)
    }
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    do {
      let leftValue = try container.decode(L.self, forKey: .left)
      self = .left(leftValue)
    }
    catch {
      let rightValue = try container.decode(R.self, forKey: .right)
      self = .right(rightValue)
    }
  }
}
