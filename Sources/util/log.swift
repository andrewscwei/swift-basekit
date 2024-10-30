import os.log
import Foundation

/// Specifies whether zen mode is enabled for logging. In zen mode, logs are
/// simplified to improve readability but unified logging is disabled.
nonisolated(unsafe) public var kZenLogging: Bool = false

/// Logs a message to the unified logging system.
///
/// - Parameters:
///   - level: The log level.
///   - isPublic: Specifies if the log is publicly accessible.
///   - isEnabled: Specifies if the log is enabled, a convenient way to skip
///                this log based on some external flag.
///   - fileName: Name of the file where this function was called.
///   - functionName: Name of the function where this function was called.
///   - lineNumber: Line number where this function was called.
///   - message: The block that returns the message.
public func log(_ level: OSLogType = .info, isPublic: Bool = true, isEnabled: Bool = true, fileName: String = #file, functionName: String = #function, lineNumber: Int = #line, message: () -> String) {
  if !isEnabled { return }

#if DEBUG
  let fileName = fileName.components(separatedBy: "/").last?.components(separatedBy: ".").first
  let subsystem = Bundle.main.bundleIdentifier ?? "app"

  if kZenLogging {
    guard level != .default else { return }
    print(getZenSymbol(for: level), message())
  }
  else {
    let category = "\(fileName ?? "???"):\(lineNumber)"

    if isPublic {
      os_log("%{public}@", log: OSLog(subsystem: subsystem, category: category), type: level, message())
    }
    else {
      os_log("%{private}@", log: OSLog(subsystem: subsystem, category: category), type: level, message())
    }
  }
#endif
}

/// Returns the logging symbol (in zen mode) of the specified log level.
///
/// - Parameters:
///   - level: The log level.
///
/// - Returns: The log symbol.
private func getZenSymbol(for level: OSLogType) -> String {
  switch level {
  case .fault: return "💀"
  case .error: return "⚠️"
  case .debug: return "👾"
  case .info: return "🤖"
  default: return ""
  }
}
