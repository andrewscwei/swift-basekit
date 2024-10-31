import Foundation

/// A type representing the current state of a `Repository`.
enum RepositoryState<T: Codable & Equatable & Sendable>: Equatable, CustomStringConvertible {

  /// `Repository` is initialzed but never synced, data is not available yet.
  case idle

  /// `Repository` is synced with data.
  case synced(T)

  var description: String {
    switch self {
    case .idle: return "idle"
    case .synced(let data): return "synced(\(data))"
    }
  }

  static func == (lhs: RepositoryState, rhs: RepositoryState) -> Bool {
    switch lhs {
    case .idle: if case .idle = rhs { return true }
    case .synced(let lhv): if case .synced(let rhv) = rhs, lhv == rhv { return true }
    }

    return false
  }
}
