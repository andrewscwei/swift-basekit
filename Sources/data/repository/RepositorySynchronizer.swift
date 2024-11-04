actor RepositorySynchronizer<T: Codable & Equatable & Sendable> {
  private var task: Task<T, Error>?
  private(set) var state: RepositoryState<T> = .initial

  func setState(_ newValue: RepositoryState<T>) {
    state = newValue
  }

  func assignTask(_ newTask: Task<T, Error>) {
    task?.cancel()
    task = newTask
  }

  func yieldTask() async throws -> T {
    guard let task = task else { throw RepositoryError.invalidSync }

    do {
      return try await task.value
    }
    catch is CancellationError {
      return try await yieldTask()
    }
    catch {
      throw RepositoryError.invalidSync(cause: error)
    }
  }
}
