import Foundation

/// Suspends execution for the specified number of seconds before resuming.
///
/// - Parameters:
///   - queue: The dispatch queue to suspend on.
///   - seconds: The number of seconds to wait before resuming.
public func delay(queue: DispatchQueue = .main, _ seconds: TimeInterval) async {
  await withCheckedContinuation { continuation in
    queue.asyncAfter(deadline: .now() + seconds) {
      continuation.resume()
    }
  }
}
