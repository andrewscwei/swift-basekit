// © Sybl

import os.log
import Foundation

/// Logs a message to the unified logging system.
///
/// - Parameters:
///   - level: The log level.
///   - isPublic: Specifies if the log is publicly accessible.
///   - isEnabled: Specifies if the log is enabled, a convenient way to skip this log based on some
///                external flag.
///   - fileName: Name of the file where this function was called.
///   - functionName: Name of the function where this function was called.
///   - lineNumber: Line number where this function was called.
///   - message: The block that returns the message.
public func log(_ level: OSLogType = .info, isPublic: Bool = true, isEnabled: Bool = true, fileName: String = #file, functionName: String = #function, lineNumber: Int = #line, message: () -> String) {
  if !isEnabled { return }

  #if DEBUG

  let fileName = fileName.components(separatedBy: "/").last?.components(separatedBy: ".").first
  let subsystem = Bundle.main.bundleIdentifier ?? "app"
  let category = "\(fileName ?? "???"):\(lineNumber)"

  if isPublic {
    os_log("%{public}@", log: OSLog(subsystem: subsystem, category: category), type: level, message())
  }
  else {
    os_log("%{private}@", log: OSLog(subsystem: subsystem, category: category), type: level, message())
  }
  #endif
}
