import Foundation

/// Creates a generic error.
///
/// - Parameters:
///   - description: The localized description of the error, can be accessed via
///                  the `localizedDescription` property of the returned
///                  `NSError` object.
///   - domain: The domain of the error.
///   - code: The code of the error.
///   - reason:The localized failure reason of the error, can be accessed via
///            the `localizedFailureReason` property of the returned `NSError`
///            object. Defaults to `description`.
///
/// - Returns:The `Error` object.
public func error(_ description: String = "Unknown error", domain: String = NSCocoaErrorDomain, code: Int = 0, reason: String? = nil) -> Error {
  NSError(domain: domain, code: code, userInfo: [
    NSLocalizedDescriptionKey: description,
    NSLocalizedFailureErrorKey: reason ?? description,
  ])
}
