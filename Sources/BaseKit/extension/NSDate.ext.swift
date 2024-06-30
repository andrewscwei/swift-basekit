import Foundation

extension NSDate {

  /// Returns the `Date` equivalent of this `NSDate`.
  ///
  /// - Returns: `Date`.
  public func asDate() -> Date {
    return Date(timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate)
  }
}
