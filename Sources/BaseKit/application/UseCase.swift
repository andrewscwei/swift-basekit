// © GHOZT

import Foundation

/// Abstract class for all use cases/interactors with an input parameter of type
/// `Input` and output value of type `Output` wrapped in a `Result`. By
/// convention, the underlying job of the `UseCase` should be suspended and
/// executed in a dispatch queue.
public protocol UseCase {
  associatedtype Input
  associatedtype Output

  /// The core operation of this `UseCase`.
  ///
  /// - Parameters:
  ///   - params: The input parameters.
  ///   - completion: The handler invoked with the `Result` upon completion.
  func run(params: Input, completion: @escaping (Result<Output, Error>) -> Void)
}
