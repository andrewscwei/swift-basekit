// © GHOZT

import Foundation

/// A type conforming to `DataSource` provides access to a type of data
/// persisted in either a local or remote origin.
public protocol DataSource {
  /// The data type associated with this data source.
  associatedtype DataType
}
