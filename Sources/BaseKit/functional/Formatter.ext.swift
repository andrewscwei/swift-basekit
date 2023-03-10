// © GHOZT

import Foundation

extension Formatter {
  /// Custom ISO 8601 date formatter with fractional seconds in the format of
  /// `yyyy-MM-dd HH:mm:ss.SSSZ`.
  public static var iso8601: ISO8601DateFormatter {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter
  }
}
