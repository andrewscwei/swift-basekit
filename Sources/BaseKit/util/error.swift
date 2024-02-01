import Foundation

/// Creates a generic error.
///
/// - Parameters:
///   - domain: The domain of the error.
///   - code: The code of the error.
///   - description: The localized description of the error, can be accessed via
///                  the `localizedDescription` property of the returned
///                  `NSError` object.
///   - reason:The localized failure reason of the error, can be accessed via
///            the `localizedFailureReason` property of the returned `NSError`
///            object. Defaults to `description`.
///
/// - Returns:The `NSError` object.
public func error(domain: String, code: Int = 0, description: String = "", reason: String? = nil) -> Error {
  NSError(domain: domain, code: code, userInfo: [
    NSLocalizedDescriptionKey: description,
    NSLocalizedFailureErrorKey: reason ?? description,
  ])
}
