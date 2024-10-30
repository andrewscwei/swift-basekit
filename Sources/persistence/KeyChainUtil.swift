import Foundation

public struct KeyChainUtil {

  public enum Error: Swift.Error {
    case read(status: OSStatus?)
    case write(status: OSStatus?)
    case delete(status: OSStatus?)
    case notFound
  }

  public static func get<T: Decodable>(service: String, group: String) throws -> T {
    let query: [String: AnyObject] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service as AnyObject,
      kSecAttrAccessGroup as String: group as AnyObject,
      kSecMatchLimit as String: kSecMatchLimitOne,
      kSecReturnAttributes as String: kCFBooleanTrue,
      kSecReturnData as String: kCFBooleanTrue,
    ]

    var result: AnyObject?

    let status = withUnsafeMutablePointer(to: &result) {
      SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
    }

    // Validate the return status.
    switch status {
    case errSecItemNotFound: throw Error.notFound
    case errSecSuccess: break
    default: throw Error.read(status: status)
    }

    guard let item = result as? [String: AnyObject], let data = item[kSecValueData as String] as? Data else {
      throw Error.notFound
    }

    do {
      let value = try JSONDecoder().decode(T.self, from: data)
      return value
    }
    catch {
      throw error
    }
  }

  public static func set<T: Encodable>(service: String, group: String, value: T) throws {
    do {
      try update(service: service, group: group, value: value)
    }
    catch {
      switch error {
      case Error.notFound: try add(service: service, group: group, value: value)
      default: throw error
      }
    }
  }

  static func add<T: Encodable>(service: String, group: String, value: T) throws {
    let encoded = try JSONEncoder().encode(value)

    let query: [String: AnyObject] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service as AnyObject,
      kSecAttrAccessGroup as String: group as AnyObject,
      kSecValueData as String: encoded as AnyObject,
    ]

    let status = SecItemAdd(query as CFDictionary, nil)

    switch status {
    case errSecSuccess: break
    default: throw Error.write(status: status)
    }
  }

  static func update<T: Encodable>(service: String, group: String, value: T) throws {
    let encoded = try JSONEncoder().encode(value)

    let attributesToUpdate: [String: AnyObject] = [
      kSecValueData as String: encoded as AnyObject,
    ]

    let query: [String: AnyObject] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service as AnyObject,
      kSecAttrAccessGroup as String: group as AnyObject,
    ]

    let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)

    switch status {
    case errSecItemNotFound: throw Error.notFound
    case errSecSuccess: break
    default: throw Error.write(status: status)
    }
  }

  public static func delete(service: String, group: String) throws {
    let query: [String: AnyObject] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service as AnyObject,
      kSecAttrAccessGroup as String: group as AnyObject,
    ]

    let status = SecItemDelete(query as CFDictionary)

    switch status {
    case errSecItemNotFound: return
    case errSecSuccess: return
    default: throw Error.delete(status: status)
    }
  }
}
