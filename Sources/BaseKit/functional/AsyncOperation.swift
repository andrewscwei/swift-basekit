// © Sybl

import Foundation

/// An abstract class that represents the code and data associated with a single asynchronous task. To use an `AsyncOperation` instance, you must add it to a `OperationQueue` or manually invoke `start()` on it.
public class AsyncOperation: Operation {

  public override var isAsynchronous: Bool { true }

  private let lockQueue: DispatchQueue

  private var mutableIsExecuting: Bool = false

  /// Indicates if the async operation is in progress.
  public private(set) override var isExecuting: Bool {
    get {
      lockQueue.sync { () -> Bool in
        mutableIsExecuting
      }
    }
    set {
      willChangeValue(for: \.isExecuting)
      lockQueue.sync(flags: [.barrier]) {
        mutableIsExecuting = newValue
      }
      didChangeValue(for: \.isExecuting)
    }
  }

  private var mutableIsFinished: Bool = false

  /// Inidicates if the async operation is complete.
  public private(set) override var isFinished: Bool {
    get {
      lockQueue.sync { () -> Bool in
        mutableIsFinished
      }
    }
    set {
      willChangeValue(for: \.isFinished)
      lockQueue.sync(flags: [.barrier]) {
        mutableIsFinished = newValue
      }
      didChangeValue(for: \.isFinished)
    }
  }

  /// Creates a new `AsyncOperation` instance.
  ///
  /// - Parameter lockQueue: A `DispatchQueue` used for thread-safe read and write access.
  public init(lockQueue: DispatchQueue = DispatchQueue.global(qos: .utility)) {
    self.lockQueue = lockQueue
  }

  /// Starts the async operation manually. Note that if this operation is added to an `OperationQueue`, `start()` will be invoked automatically.
  public override func start() {
    guard !isCancelled else {
      finish()
      return
    }

    isFinished = false
    isExecuting = true
    main()
  }

  /// This is the main executing block representing the async operation and must be overridden by subclasses of `AsyncOperation`.
  public override func main() {
    fatalError("Subclass must override `main()` without calling `super`, and call `finish()` when done")
  }

  /// Override this to define what happens when the operation cancels.
  public override func cancel() {
    super.cancel()
  }

  /// Signifies the the async operation as complete.
  public func finish() {
    isExecuting = false
    isFinished = true
  }
}
