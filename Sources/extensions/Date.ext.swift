import Foundation

extension Date {

  /// Returns the date in ISO 8601 (`yyyy-MM-dd HH:mm:ss.SSSZ`) format.
  @available(iOS 11.0, *)
  public var iso8601: String {
    return Formatter.iso8601.string(from: self)
  }

  /// Returns an `NSDate` equivalent of this `Date`.
  ///
  /// - Returns: `NSDate`.
  public func asNSDate() -> NSDate {
    return NSDate(timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate)
  }
}
