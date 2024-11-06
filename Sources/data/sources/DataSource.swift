/// A type conforming to `DataSource` provides an interface to access data from
/// an underlying storage mechanism.
///
/// `associatedtype`:
///   - `DataType`: The data type associated with this data source.
public protocol DataSource: Sendable {
  associatedtype DataType: Sendable
}
