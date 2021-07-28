// © Sybl

import Foundation

public class AsyncOperation: Operation {

  private let lockQueue: DispatchQueue

  public override var isAsynchronous: Bool { true }

  private var mutableIsExecuting: Bool = false

  public override private(set) var isExecuting: Bool {
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

  public override private(set) var isFinished: Bool {
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

  public init(lockQueue: DispatchQueue) {
    self.lockQueue = lockQueue
  }

  public override func start() {
    guard !isCancelled else {
      finish()
      return
    }

    isFinished = false
    isExecuting = true
    main()
  }

  public override func main() {
    fatalError("main() is not implemented by subclass")
  }

  public func finish() {
    isExecuting = false
    isFinished = true
  }
}
