import Foundation

extension Date {

  /// Returns an `NSDate` equivalent of this `Date`.
  ///
  /// - Returns: `NSDate`.
  public func asNSDate() -> NSDate {
    return NSDate(timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate)
  }
}
