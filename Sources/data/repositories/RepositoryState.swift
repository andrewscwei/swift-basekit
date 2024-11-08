/// A type representing the current state of a `Repository`.
public enum RepositoryState<T: RepositoryData>: Equatable, CustomStringConvertible, Sendable {

  /// `Repository` is initialized but never synced, data is not available yet.
  case initial

  /// `Repository` is synced with data.
  case synced(T)

  /// `Repository` attempted a sync but failed, previous data is retained.
  case notSynced(T)

  public var description: String {
    switch self {
    case .initial: return "initial"
    case .synced(let data): return "synced(\(data))"
    case .notSynced(let data): return "notSynced(\(data))"
    }
  }

  public static func == (lhs: RepositoryState, rhs: RepositoryState) -> Bool {
    switch lhs {
    case .initial: if case .initial = rhs { return true }
    case .synced(let lhv): if case .synced(let rhv) = rhs, lhv == rhv { return true }
    case .notSynced(let lhv): if case .notSynced(let rhv) = rhs, lhv == rhv { return true }
    }

    return false
  }
}
