import Foundation

/// A type conforming to `DataSource` provides an interface to access data from
/// a local or remote origin.
public protocol DataSource {
  /// The data type associated with this data source.
  associatedtype DataType
}
