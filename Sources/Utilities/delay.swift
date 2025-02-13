import Foundation

/// Suspends execution for the specified number of seconds before resuming.
///
/// - Parameters:
///   - seconds: The number of seconds to wait before resuming.
public func delay(_ seconds: TimeInterval) async {
  try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
}

/// Suspends execution for the specified number of seconds before resuming.
///
/// - Parameters:
///   - seconds: The number of seconds to wait before resuming.
///   - queue: The dispatch queue to suspend on.
public func delay(_ seconds: TimeInterval, queue: DispatchQueue) async {
  await withCheckedContinuation { continuation in
    queue.asyncAfter(deadline: .now() + seconds) {
      continuation.resume()
    }
  }
}

/// Executes a closure after a delay in seconds, returning immediately.
///
/// - Parameters:
///   - seconds: The number of seconds to wait before executing the closure.
///   - queue: The dispatch queue to execute the closure on.
///   - execute: The closure to execute.
public func delay(_ seconds: TimeInterval, queue: DispatchQueue = .global(qos: .utility), execute: @escaping @Sendable () -> Void) {
  queue.asyncAfter(deadline: .now() + seconds, execute: execute)
}
