// © Sybl

import Foundation

extension String {

  /// Converts this string to a date in ISO 8601 format.
  ///
  /// - Returns: The date in ISO 8601 format.
  public func toFormattedDate() -> Date? {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"

    return formatter.date(from: self)
  }
}
