/// An actor responsible for synchronizing `Repository` data in a concurrent-
/// safe manner. It manages an asynchronous task and maintains the state of the
/// `Repository`.
public actor RepositorySynchronizer<T: RepositoryData> {

  private var observers: [WeakReference<RepositoryObserver>] = []
  private var task: Task<T, Error>?

  /// The current state of the `Repository`. This property is readonly from
  /// outside the actor and can be updated only within the actor.
  public private(set) var state: RepositoryState<T> = .initial

  /// Updates the state of the `Repository`.
  ///
  /// - Parameters:
  ///   - newValue: The new state to set.
  func setState(_ newValue: RepositoryState<T>) {
    state = newValue
  }

  /// Assigns a new task for data synchronization, canceling any previously
  /// running task.
  ///
  /// - Parameters:
  ///   - newTask: The new `Task` to be assigned for synchronization.
  func assignTask(_ newTask: Task<T, Error>) {
    task?.cancel()
    task = newTask
  }

  /// Awaits the result of the currently assigned task. If the task is canceled,
  /// this method retries until it successfully completes or fails with an
  /// error.
  ///
  /// - Returns: The result of the completed task.
  /// - Throws: `RepositoryError.invalidSync` if there is no active task or if
  ///           the task fails with an error.
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

  func addObserver(_ observer: any RepositoryObserver) {
    observers = observers.filter { $0.get() as AnyObject !== observer as AnyObject } + [WeakReference(observer)]
  }

  func removeObserver(_ observer: any RepositoryObserver) {
    observers = observers.filter { $0.get() as AnyObject !== observer as AnyObject }
  }

  func notifyObservers(iteratee: @escaping @Sendable (any RepositoryObserver) -> Void) {
    observers.compactMap { $0.get() }.forEach(iteratee)
  }
}
