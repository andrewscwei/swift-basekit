/// A type conforming to `Datasource` provides an interface to access data from
/// a local or remote origin.
public protocol Datasource: Sendable {

  /// The data type associated with this datasource.
  associatedtype DataType: Sendable
}
