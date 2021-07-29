// © Sybl

import Foundation

extension Formatter {

  /// ISO 8601 date formatter in the format of `yyyy-MM-dd HH:mm:ss.SSSZ`.
  @available(iOS 11.0, *)
  public static let iso8601 = ISO8601DateFormatter([.withInternetDateTime, .withFractionalSeconds])
}
