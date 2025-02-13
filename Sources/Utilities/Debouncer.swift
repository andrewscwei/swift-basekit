import Foundation

/// A utility class that delays the execution of a task until after a specified
/// time interval. This is useful for debouncing rapid successive calls to a
/// function, ensuring that it executes only once after the last call within the
/// given time frame.
public final class Debouncer {
  private let delay: TimeInterval
  private var timer: Timer?

  /// Initializes a `Debouncer` with the specified delay.
  ///
  /// - Parameters:
  ///   - delay: The time interval (in seconds) to wait before executing the
  ///            action.
  public init(delay: TimeInterval) {
    self.delay = delay
  }

  /// Invalidates the timer when the instance is deallocated.
  deinit {
    timer?.invalidate()
  }

  /// Schedules the execution of the given action, canceling any previously
  /// scheduled execution.
  ///
  /// If this method is called multiple times within the `delay` interval, only
  /// the most recent invocation's action will be executed, ensuring that rapid
  /// calls do not trigger multiple executions.
  ///
  /// - Parameters:
  ///   - action: The closure to be executed after the delay.
  public func call(action: @escaping @Sendable () -> Void) {
    timer?.invalidate()

    timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
      action()
    }
  }
}
