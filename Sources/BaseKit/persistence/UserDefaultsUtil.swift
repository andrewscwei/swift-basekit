import Foundation

public struct UserDefaultsUtil {

  enum Error: Swift.Error {
    case typeMismatch(cause: Swift.Error?)
  }

  /// Retrieves a value from `UserDefaults` using the specified key. If the
  /// value does not exist, `nil` will be returned. If the value cannot be
  /// decoded to type `T`, an error will be thrown.
  ///
  /// - Parameters:
  ///   - key: The key to look up.
  ///
  /// - Returns: The value stored in `UserDefaults`, `nil` if it does not exist
  ///            or cannot be typecast to `T`.
  ///
  /// - Throws: If the retrieved value cannot be decoded to type `T`.
  public static func get<T: Codable>(_ key: String) throws -> T? {
    guard let object = UserDefaults.standard.object(forKey: key) else { return nil }
    guard let data = object as? Data else { throw Error.typeMismatch(cause: nil) }

    do {
      let value = try JSONDecoder().decode(T.self, from: data)
      return value
    }
    catch {
      throw Error.typeMismatch(cause: error)
    }
  }

  /// Retrieves a value from `UserDefaults` using the specified key. If the
  /// value does not exist or it cannot be typecast to `T`, the default value
  /// will be written to `UserDefaults` at the specified key and returned.
  ///
  /// - Parameters:
  ///   - key: The key to look up.
  ///   - defaultValue: The default value to use in case a value does not exist
  ///                   or cannot be typecast to `T`.
  ///
  /// - Returns: The value stored in `UserDefaults`, or `defaultValue` if it
  ///            does not exist or cannot be typecast to `T`.
  ///
  /// - Throws: If there is an error setting the default value.
  public static func get<T: Codable>(_ key: String, default defaultValue: T) throws -> T {
    if let value: T = try? get(key) {
      return value
    }

    try set(key, value: defaultValue)
    return defaultValue
  }

  /// Sets a value at the specified key in `UserDefaults`. If `T` is optional
  /// and the value to set is `nil`, the key will be removed from
  /// `UserDefaults`.
  ///
  /// - Parameters:
  ///   - key: The key to look up.
  ///   - newValue: The new value to set. If this is `nil`, the key will be
  ///               removed from `UserDefaults`.
  ///
  /// - Throws: If there is an error encoding the value.
  public static func set<T: Codable>(_ key: String, value: T) throws {
    if let optionalValue = value as? AnyOptional, optionalValue.isNil {
      UserDefaults.standard.removeObject(forKey: key)
    }
    else {
      do {
        let data = try JSONEncoder().encode(value)
        UserDefaults.standard.set(data, forKey: key)
      }
      catch {
        throw Error.typeMismatch(cause: error)
      }
    }
  }
}
