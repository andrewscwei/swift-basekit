// © Sybl

import Foundation

public final class Debouncer {
  private let delay: TimeInterval
  private var timer: Timer?

  public init(delay: TimeInterval) {
    self.delay = delay
  }

  deinit {
    timer?.invalidate()
  }

  public func call(action: @escaping @Sendable () -> Void) {
    timer?.invalidate()

    timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
      action()
    }
  }
}
