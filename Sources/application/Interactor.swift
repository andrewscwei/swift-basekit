public protocol Interactor {

  /// Interacts with a `UseCase`.
  ///
  /// - Parameters:
  ///   - useCase: The use case to interact with.
  ///   - params: The input parameters of the `UseCase`.
  /// - Returns: The output of the use case.
  /// - Throws: When interacting with the use case fails.
  func interact<T: UseCase>(_ useCase: T, params: T.Input) async throws -> T.Output

  /// Interacts with a `UseCase` with no input type.
  ///
  /// - Parameters:
  ///   - useCase: The use case to interact with.
  /// - Returns: The output of the use case.
  /// - Throws: When interacting with the use case fails.
  func interact<T: UseCase>(_ useCase: T) async throws -> T.Output where T.Input == Void

  /// Handler invoked before interacting with a use case.
  ///
  /// - Parameters:
  ///   -  useCase: The use case to interact with.
  func willInteractWithUseCase<T: UseCase>(_ useCase: T)

  /// Handler invoked after interacting with a use case.
  ///
  /// - Parameters:
  ///   - useCase: The use case.
  ///   - result: The result.
  func didInteractWithUseCase<T: UseCase>(_ useCase: T, result: Result<T.Output, Error>)
}

extension Interactor {
  @discardableResult
  public func interact<T: UseCase>(_ useCase: T, params: T.Input) async throws -> T.Output {
    _log.debug { "Running use case \(T.self)...\n↘︎ params=\(params)" }

    do {
      let result = try await useCase.run(params: params)

      _log.debug { "Running use case \(T.self)... OK\n↘︎ result=\(result)" }

      self.didInteractWithUseCase(useCase, result: .success(result))

      return result
    }
    catch {
      _log.error { "Running use case \(T.self)... ERR\n↘︎ error=\(error)" }

      self.didInteractWithUseCase(useCase, result: .failure(error))

      throw error
    }
  }

  @discardableResult
  public func interact<T: UseCase>(_ useCase: T) async throws -> T.Output where T.Input == Void {
    _log.debug { "Running use case \(T.self)..." }

    do {
      let result = try await useCase.run(params: ())

      _log.debug { "Running use case \(T.self)... OK\n↘︎ result=\(result)" }

      didInteractWithUseCase(useCase, result: .success(result))

      return result
    }
    catch {
      _log.error { "Running use case \(T.self)... ERR\n↘︎ error=\(error)" }

      didInteractWithUseCase(useCase, result: .failure(error))

      throw error
    }
  }

  public func willInteractWithUseCase<T: UseCase>(_ useCase: T) {}

  public func didInteractWithUseCase<T: UseCase>(_ useCase: T, result: Result<T.Output, Error>) {}
}
