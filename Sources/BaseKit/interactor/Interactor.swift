// © GHOZT

public protocol Interactor {
  /// Indicates whether debug logging is enabled.
  var debugMode: Bool { get }

  /// Interacts with a `UseCase` with an input type `T`.
  ///
  /// - Parameters:
  ///   - useCase: The `UseCase` to interact.
  ///   - params: The input parameters of the `UseCase`.
  ///   - completion: Handler invoked upon completion, with the `Result`
  ///                wrapping the output of the `UseCase` as its success value.
  func interact<T: UseCase>(_ useCase: T, params: T.Input, completion: @escaping (Result<T.Output, Error>) -> Void)

  /// Interacts with a `UseCase` with no input type.
  ///
  /// - Parameters:
  ///   - useCase: The `UseCase` to interact.
  ///   - completion: Handler invoked upon completion, with the `Result`
  ///                wrapping the output of the `UseCase` as its success value.
  func interact<T: UseCase>(_ useCase: T, completion: @escaping (Result<T.Output, Error>) -> Void) where T.Input == Void


  /// Handler invoked before interacting with a use case.
  ///
  /// - Parameters:
  ///   -  useCase: The use case to interact with.
  func willInteractWithUseCase<T: UseCase>(_ useCase: T)

  /// Handler invoked after interacting with a use case.
  ///
  /// - Parameters:
  ///   - useCase: The use case interacted.
  ///   - result: The result.
  func didInteractWithUseCase<T: UseCase>(_ useCase: T, result: Result<T.Output, Error>)
}

extension Interactor {
  public var debugMode: Bool { false }

  public func interact<T: UseCase>(_ useCase: T, params: T.Input, completion: @escaping (Result<T.Output, Error>) -> Void = { _ in }) {
    log(.debug, isEnabled: debugMode) { "Running use case \(T.self) with params \(params)..." }

    useCase.run(params: params) { result in
      switch result {
      case .failure(let error): log(.error, isEnabled: self.debugMode) { "Running use case \(T.self) with params \(params)... ERR: \(error)" }
      case .success(let data): log(.debug, isEnabled: self.debugMode) { "Running use case \(T.self) with params \(params)... OK: \(data)" }
      }

      self.didInteractWithUseCase(useCase, result: result)

      completion(result)
    }
  }

  public func interact<T: UseCase>(_ useCase: T, completion: @escaping (Result<T.Output, Error>) -> Void = { _ in }) where T.Input == Void {
    log(.debug, isEnabled: debugMode) { "Running use case \(T.self)..." }

    useCase.run(params: ()) { result in
      switch result {
      case .failure(let error): log(.error, isEnabled: self.debugMode) { "Running use case \(T.self)... ERR: \(error)" }
      case .success(let data): log(.debug, isEnabled: self.debugMode) { "Running use case \(T.self)... OK: \(data)" }
      }

      self.didInteractWithUseCase(useCase, result: result)

      completion(result)
    }
  }

  public func willInteractWithUseCase<T: UseCase>(_ useCase: T) {}

  public func didInteractWithUseCase<T: UseCase>(_ useCase: T, result: Result<T.Output, Error>) {}
}
