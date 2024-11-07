import os.log
import Foundation

/// A simple logger that can log messages to the unified logging system or to
/// the console (default).
public struct Log: Sendable {
  public enum Mode: Sendable {
    case none
    case unified
    case console
  }

  let mode: Mode
  let prefix: String?

  public init(mode: Mode) {
    self.mode = mode
    self.prefix = nil
  }

  public init(mode: Mode, prefix: String) {
    self.mode = mode
    self.prefix = prefix
  }

  /// Logs a message to the unified logging system in the `default` level.
  ///
  /// Log level priorities are as follows, from highest to lowest:
  ///   1. `fault`
  ///   2. `error`
  ///   3. `debug`
  ///   4. `info`
  ///   5. `default`
  ///
  /// - Parameters:
  ///   - message: The message.
  ///   - isPublic: Specifies if the log is publicly accessible.
  ///   - fileName: Name of the file where this function was called.
  ///   - functionName: Name of the function where this function was called.
  ///   - lineNumber: Line number where this function was called.
  public func callAsFunction(_ message: String, isPublic: Bool = true, fileName: String = #file, functionName: String = #function, lineNumber: Int = #line) {
    log(message, level: .default, isPublic: isPublic, fileName: fileName, functionName: functionName, lineNumber: lineNumber)
  }

  /// Logs a message to the unified logging system in the `info` level.
  ///
  /// Log level priorities are as follows, from highest to lowest:
  ///   1. `fault`
  ///   2. `error`
  ///   3. `debug`
  ///   4. `info`
  ///   5. `default`
  ///
  /// - Parameters:
  ///   - message: The message.
  ///   - isPublic: Specifies if the log is publicly accessible.
  ///   - fileName: Name of the file where this function was called.
  ///   - functionName: Name of the function where this function was called.
  ///   - lineNumber: Line number where this function was called.
  public func info(_ message: String, isPublic: Bool = true, fileName: String = #file, functionName: String = #function, lineNumber: Int = #line) {
    log(message, level: .info, isPublic: isPublic, fileName: fileName, functionName: functionName, lineNumber: lineNumber)
  }

  /// Logs a message to the unified logging system in the `debug` level.
  ///
  /// Log level priorities are as follows, from highest to lowest:
  ///   1. `fault`
  ///   2. `error`
  ///   3. `debug`
  ///   4. `info`
  ///   5. `default`
  ///
  /// - Parameters:
  ///   - message: The message.
  ///   - isPublic: Specifies if the log is publicly accessible.
  ///   - fileName: Name of the file where this function was called.
  ///   - functionName: Name of the function where this function was called.
  ///   - lineNumber: Line number where this function was called.
  public func debug(_ message: String, isPublic: Bool = true, fileName: String = #file, functionName: String = #function, lineNumber: Int = #line) {
    log(message, level: .debug, isPublic: isPublic, fileName: fileName, functionName: functionName, lineNumber: lineNumber)
  }

  /// Logs a message to the unified logging system in the `error` level.
  ///
  /// Log level priorities are as follows, from highest to lowest:
  ///   1. `fault`
  ///   2. `error`
  ///   3. `debug`
  ///   4. `info`
  ///   5. `default`
  ///
  /// - Parameters:
  ///   - message: The message.
  ///   - isPublic: Specifies if the log is publicly accessible.
  ///   - fileName: Name of the file where this function was called.
  ///   - functionName: Name of the function where this function was called.
  ///   - lineNumber: Line number where this function was called.
  public func error(_ message: String, isPublic: Bool = true, fileName: String = #file, functionName: String = #function, lineNumber: Int = #line) {
    log(message, level: .error, isPublic: isPublic, fileName: fileName, functionName: functionName, lineNumber: lineNumber)
  }

  /// Logs a message to the unified logging system in the `fault` level.
  ///
  /// Log level priorities are as follows, from highest to lowest:
  ///   1. `fault`
  ///   2. `error`
  ///   3. `debug`
  ///   4. `info`
  ///   5. `default`
  ///
  /// - Parameters:
  ///   - message: The message.
  ///   - isPublic: Specifies if the log is publicly accessible.
  ///   - fileName: Name of the file where this function was called.
  ///   - functionName: Name of the function where this function was called.
  ///   - lineNumber: Line number where this function was called.
  public func fault(_ message: String, isPublic: Bool = true, fileName: String = #file, functionName: String = #function, lineNumber: Int = #line) {
    log(message, level: .fault, isPublic: isPublic, fileName: fileName, functionName: functionName, lineNumber: lineNumber)
  }

  private func log(_ message: String, level: OSLogType = .info, isPublic: Bool, fileName: String, functionName: String, lineNumber: Int) {
    guard mode != .none else { return }

#if !DEBUG
    guard  level != .debug else { return }
#endif

    let message = [prefix, getSymbol(for: level), message].compactMap { $0 }.joined(separator: " ")

    if mode == .unified {
      let fileName = fileName.components(separatedBy: "/").last?.components(separatedBy: ".").first
      let subsystem = Bundle.main.bundleIdentifier ?? "app"
      let category = "\(fileName ?? "???"):\(lineNumber)"

      if isPublic {
        os_log("%{public}@", log: OSLog(subsystem: subsystem, category: category), type: level, message)
      }
      else {
        os_log("%{private}@", log: OSLog(subsystem: subsystem, category: category), type: level, message)
      }
    }
    else {
      print(message)
    }
  }

  private func getSymbol(for level: OSLogType) -> String? {
    switch level {
    case .fault: return "💀"
    case .error: return "⚠️"
    case .debug: return "👾"
    case .info: return "ℹ️"
    default: return nil
    }
  }
}

#if BASEKIT_DEBUG
/// Internal logger instance.
let _log = Log(mode: .console, prefix: "[🤖]")
#else
let _log = Log(mode: .none)
#endif
