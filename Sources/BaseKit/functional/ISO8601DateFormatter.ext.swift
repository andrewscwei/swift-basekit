// © Sybl

import Foundation

extension ISO8601DateFormatter {

  /// Initializes an `ISO8601DateFormatter` with specified format options and time zone.
  ///
  /// - Parameters:
  ///   - formatOptions: Format options.
  ///   - timeZone: Time zone.
  convenience init(_ formatOptions: Options, timeZone: TimeZone = TimeZone(secondsFromGMT: 0)!) {
    self.init()
    self.formatOptions = formatOptions
    self.timeZone = timeZone
  }
}
