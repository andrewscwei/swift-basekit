// © GHOZT

import Foundation

/// A `Repository` with read-only access to its data source(s).
public typealias ReadOnlyRepository<T: Codable & Equatable> = Repository<T>
