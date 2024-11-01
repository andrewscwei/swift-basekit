public struct BaseKitConfigurator: Sendable {
  enum LoggerType {
    case none
    case console
    case unified
  }

  struct Configuration {
    var logger: LoggerType = .console
    var debugMode: Bool = false
  }

  func configure(mutate: (inout Configuration) -> Void) {
    var config = Configuration()
    mutate(&config)

    _log.isEnabled = config.debugMode
    log.isEnabled = config.logger != .none
    log.usesUnifiedLogging = config.logger == .unified
  }
}

public let BaseKit = BaseKitConfigurator()
