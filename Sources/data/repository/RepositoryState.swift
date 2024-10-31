import Foundation

/// A type representing the current state of a `Repository`.
enum RepositoryState<T: Codable & Equatable>: Equatable, CustomStringConvertible {
  case synced(T)
  case notSynced

  var description: String {
    switch self {
    case .notSynced: return "notSynced"
    case .synced(let data): return "synced(\(data))"
    }
  }

  static func == (lhs: RepositoryState, rhs: RepositoryState) -> Bool {
    switch lhs {
    case .notSynced: if case .notSynced = rhs { return true }
    case .synced(let lhv): if case .synced(let rhv) = rhs, lhv == rhv { return true }
    }

    return false
  }
}
