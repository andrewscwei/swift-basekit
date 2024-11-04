/// A type conforming to `Datasource` provides an interface to access data from
/// an underlying storage mechanism.
///
/// `associatedtype`:
///   - `DataType`: The data type associated with this datasource.
public protocol Datasource: Sendable {
  associatedtype DataType: Sendable
}
