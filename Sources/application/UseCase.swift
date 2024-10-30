import Foundation

/// Abstract class for implementing use cases. Specify `Input` and `Output`
/// types.
///
/// Associated types:
/// - `Input`: Parameters passed to the use case upon invocation
/// - `Output`: Return type when invocation succeeds
///
/// The implementation body of `run` may be suspended and executed in a dispatch
/// queue.
public protocol UseCase {
  associatedtype Input
  associatedtype Output

  /// Invokes the `UseCase`.
  ///
  /// - Parameters:
  ///   - params: The input parameters.
  ///   - completion: The handler invoked with the `Result` upon completion.
  func run(params: Input, completion: @escaping (Result<Output, Error>) -> Void)
}
