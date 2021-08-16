// © Sybl

import Foundation

/// An abstract class that represents the code and data associated with a single asynchronous task.
/// To use an `AsyncOperation`, you must either add it to a `OperationQueue` or manually invoke
/// `start()` on it.
open class AsyncOperation: Operation {

  public override var isAsynchronous: Bool { true }

  private let queue: DispatchQueue

  private var mutableIsExecuting: Bool = false

  /// Indicates if the async operation is in progress.
  public private(set) override var isExecuting: Bool {
    get {
      queue.sync { () -> Bool in
        mutableIsExecuting
      }
    }
    set {
      willChangeValue(for: \.isExecuting)
      queue.sync(flags: [.barrier]) {
        mutableIsExecuting = newValue
      }
      didChangeValue(for: \.isExecuting)
    }
  }

  private var mutableIsFinished: Bool = false

  /// Indicates if the async operation is complete.
  public private(set) override var isFinished: Bool {
    get {
      queue.sync { () -> Bool in
        mutableIsFinished
      }
    }
    set {
      willChangeValue(for: \.isFinished)
      queue.sync(flags: [.barrier]) {
        mutableIsFinished = newValue
      }
      didChangeValue(for: \.isFinished)
    }
  }

  /// Creates a new `AsyncOperation` instance.
  ///
  /// - Parameter queue: A `DispatchQueue` used for thread-safe read and write access.
  public init(queue: DispatchQueue = DispatchQueue.global(qos: .utility)) {
    self.queue = queue
  }

  /// Starts the async operation manually. Note that if this operation is added to an
  /// `OperationQueue`, `start()` will be invoked automatically.
  public override func start() {
    guard !isCancelled else {
      finish()
      return
    }

    isFinished = false
    isExecuting = true
    main()
  }

  /// The main executing block running the async operation that must be overridden by subclasses.
  public override func main() {
    fatalError("Subclass must override `main()` without calling `super`, and call `finish()` when done")
  }

  /// Override this to define what happens when the operation cancels.
  public override func cancel() {
    super.cancel()
  }

  /// Notifies that the async operation as complete.
  public func finish() {
    isExecuting = false
    isFinished = true
  }
}
