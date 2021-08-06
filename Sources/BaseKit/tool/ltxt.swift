// © Sybl

import Foundation

/// Convenience method for returning a localized string from the main bundle. Providing a comment is optional, and is
/// otherwise automatically set to the same value as the key.
///
/// - Parameters:
///   - key: Localization key.
///   - default: Optional default value for this localization, defaults to the value of the localization key.
///   - comment: Optional comment for this localization, defaults to the value of the localization key.
///
/// - Returns: The localized string.
public func ltxt(_ key: String, default defaultValue: String? = nil, comment: String? = nil) -> String {
  return NSLocalizedString(key, tableName: nil, bundle: Bundle.main, value: defaultValue ?? key, comment: comment ?? key)
}
