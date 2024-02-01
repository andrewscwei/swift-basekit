import Foundation

/// A container for data stored in a `Repository`.
enum RepositoryData<T: Codable & Equatable>: Equatable, CustomStringConvertible {
  case synced(T)
  case notSynced

  var description: String {
    switch self {
    case .notSynced: return "notSynced"
    case .synced(let value): return "synced(\(value))"
    }
  }

  static func == (lhs: RepositoryData, rhs: RepositoryData) -> Bool {
    switch lhs {
    case .notSynced: if case .notSynced = rhs { return true }
    case .synced(let lhv): if case .synced(let rhv) = rhs, lhv == rhv { return true }
    }

    return false
  }
}
