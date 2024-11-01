public protocol Interactor {
  /// Interacts with a `UseCase`.
  ///
  /// - Parameters:
  ///   - useCase: The `UseCase` to interact with.
  ///   - params: The input parameters of the `UseCase`.
  ///
  /// - Returns: The output of the use case.
  func interact<U: UseCase>(_ useCase: U, params: U.Input) async throws -> U.Output

  /// Interacts with a `UseCase` with no input type.
  ///
  /// - Parameters:
  ///   - useCase: The `UseCase` to interact.
  ///
  /// - Returns: The output of the use case.
  func interact<U: UseCase>(_ useCase: U) async throws -> U.Output where U.Input == Void


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
  public func interact<U: UseCase>(_ useCase: U, params: U.Input) async throws -> U.Output {
    _log.debug("Running use case \(U.self) with params \(params)...")

    do {
      let result = try await useCase.run(params: params)

      _log.debug("Running use case \(U.self) with params \(params)... OK: \(result)")

      self.didInteractWithUseCase(useCase, result: .success(result))

      return result
    }
    catch {
      _log.error("Running use case \(U.self) with params \(params)... ERR: \(error)")

      self.didInteractWithUseCase(useCase, result: .failure(error))

      throw error
    }
  }

  public func interact<U: UseCase>(_ useCase: U) async throws -> U.Output where U.Input == Void {
    _log.debug("Running use case \(U.self)...")

    do {
      let result = try await useCase.run(params: ())

      _log.debug("Running use case \(U.self)... OK: \(result)")

      didInteractWithUseCase(useCase, result: .success(result))

      return result
    }
    catch {
      _log.error("Running use case \(U.self)... ERR: \(error)")

      didInteractWithUseCase(useCase, result: .failure(error))

      throw error
    }
  }

  public func willInteractWithUseCase<U: UseCase>(_ useCase: U) {}

  public func didInteractWithUseCase<U: UseCase>(_ useCase: U, result: Result<U.Output, Error>) {}
}
