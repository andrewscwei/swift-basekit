// © Sybl

import Foundation

/// Executes a block after the specified number of seconds and returns immediately.
///
/// - Parameters:
///   - queue: The dispatch queue to execute the block on.
///   - seconds: The number of seconds to wait for before executing the block.
///   - execute: The block to execute.
public func delay(queue: DispatchQueue = DispatchQueue.main, _ seconds: TimeInterval, execute: @escaping () -> Void) {
  queue.asyncAfter(deadline: .now() + seconds, execute: execute)
}
