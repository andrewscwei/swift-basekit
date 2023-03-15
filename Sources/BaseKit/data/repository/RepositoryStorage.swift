// © GHOZT

import Foundation

enum RepositoryStorage<T: Codable & Equatable>: Equatable, CustomStringConvertible {
  case synced(T)
  case notSynced

  var description: String {
    switch self {
    case .notSynced: return "n/a"
    case .synced(let value): return "\(value)"
    }
  }

  static func == (lhs: RepositoryStorage, rhs: RepositoryStorage) -> Bool {
    switch lhs {
    case .notSynced: if case .notSynced = rhs { return true }
    case .synced(let lhv): if case .synced(let rhv) = rhs, lhv == rhv { return true }
    }

    return false
  }
}
