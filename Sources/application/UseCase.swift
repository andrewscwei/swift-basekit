/// A protocol for defining use cases with specified `Input` and `Output` types.
///
/// Use cases represent distinct, self-contained tasks or operations in your
/// application's business logic. This protocol defines the structure for
/// invoking such tasks asynchronously.
///
/// - `associatedtype`:
///   - `Input`: The type of parameters required to invoke the use case.
///   - `Output`: The type of the result produced when the use case completes
///               successfully.
public protocol UseCase {
  associatedtype Input
  associatedtype Output

  /// Executes the use case with the given parameters.
  ///
  /// - Parameters:
  ///   - params: The input parameters required to run the use case.
  /// - Returns: The output produced after successfully running the use case.
  /// - Throws: An error if the use case fails during execution.
  func run(params: Input) async throws -> Output
}
