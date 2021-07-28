// © Sybl

import os.log
import Foundation

/// Logs a message to the unified logging system.
///
/// - Parameters:
///   - level: The log level.
///   - isPublic: Indicates if the log is publicly accessible.
///   - fileName: Name of the file where the log was invoked.
///   - functionName: Name of the function where the log was invoked.
///   - lineNumber: Line number where the log was invoked.
///   - message: The block that returns the message.
public func log(_ level: OSLogType = .info, isPublic: Bool = true, fileName: String = #file, functionName: String = #function, lineNumber: Int = #line, message: () -> String) {
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
