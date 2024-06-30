import Foundation

extension String {
  /// Converts this string to a `Date` object in ISO 8601 format, assuming the
  /// string represents the date with fractional seconds in `yyyy-MM-dd
  /// HH:mm:ss.SSSZ` format.
  ///
  /// - Returns: The `Date` in ISO 8601 format.
  public func toISO8601Date() -> Date? {
    if #available(iOS 11.0, *) {
      return Formatter.iso8601.date(from: self)
    }
    else {
      let formatter = DateFormatter()
      formatter.calendar = Calendar(identifier: .iso8601)
      formatter.locale = Locale(identifier: "en_US_POSIX")
      formatter.timeZone = TimeZone(secondsFromGMT: 0)
      formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"

      return formatter.date(from: self)
    }
  }
}
