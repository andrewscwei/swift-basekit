import Foundation

/// Protocol for a write/delete `DataSource`.
public protocol WriteDeleteDataSource: WriteOnlyDataSource {
  /// Deletes the existing data from the data source.
  func delete() async throws
}
