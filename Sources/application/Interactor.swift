/// Specifies whether debug mode is enabled for `Interactor` instances.
nonisolated(unsafe) public var kInteractorDebugMode = false

public protocol Interactor {
  /// Indicates whether debug logging is enabled.
  var debugMode: Bool { get }

  /// Interacts with a `UseCase` with an input type `U`.
  ///
  /// - Parameters:
  ///   - useCase: The `UseCase` to interact.
  ///   - params: The input parameters of the `UseCase`.
  ///   - completion: Handler invoked upon completion, with the `Result`
  ///                wrapping the output of the `UseCase` as its success value.
  func interact<U: UseCase>(_ useCase: U, params: U.Input, completion: @escaping (Result<U.Output, Error>) -> Void)

  /// Interacts with a `UseCase` with no input type.
  ///
  /// - Parameters:
  ///   - useCase: The `UseCase` to interact.
  ///   - completion: Handler invoked upon completion, with the `Result`
  ///                wrapping the output of the `UseCase` as its success value.
  func interact<U: UseCase>(_ useCase: U, completion: @escaping (Result<U.Output, Error>) -> Void) where U.Input == Void


  /// Handler invoked before interacting with a use case.
  ///
  /// - Parameters:
  ///   -  useCase: The use case to interact with.
  func willInteractWithUseCase<U: UseCase>(_ useCase: U)

  /// Handler invoked after interacting with a use case.
  ///
  /// - Parameters:
  ///   - useCase: The use case interacted.
  ///   - result: The result.
  func didInteractWithUseCase<U: UseCase>(_ useCase: U, result: Result<U.Output, Error>)
}

extension Interactor {
  public var debugMode: Bool { kInteractorDebugMode }

  public func interact<U: UseCase>(_ useCase: U, params: U.Input, completion: @escaping (Result<U.Output, Error>) -> Void = { _ in }) {
    log(.debug, isEnabled: debugMode) { "Running use case \(U.self) with params \(params)..." }

    useCase.run(params: params) { result in
      switch result {
      case .failure(let error): log(.error, isEnabled: self.debugMode) { "Running use case \(U.self) with params \(params)... ERR: \(error)" }
      case .success(let data): log(.debug, isEnabled: self.debugMode) { "Running use case \(U.self) with params \(params)... OK: \(data)" }
      }

      self.didInteractWithUseCase(useCase, result: result)

      completion(result)
    }
  }

  public func interact<U: UseCase>(_ useCase: U, completion: @escaping (Result<U.Output, Error>) -> Void = { _ in }) where U.Input == Void {
    log(.debug, isEnabled: debugMode) { "Running use case \(U.self)..." }

    useCase.run(params: ()) { result in
      switch result {
      case .failure(let error): log(.error, isEnabled: self.debugMode) { "Running use case \(U.self)... ERR: \(error)" }
      case .success(let data): log(.debug, isEnabled: self.debugMode) { "Running use case \(U.self)... OK: \(data)" }
      }

      self.didInteractWithUseCase(useCase, result: result)

      completion(result)
    }
  }

  public func willInteractWithUseCase<U: UseCase>(_ useCase: U) {}

  public func didInteractWithUseCase<U: UseCase>(_ useCase: U, result: Result<U.Output, Error>) {}
}
