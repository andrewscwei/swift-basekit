import XCTest
@testable import BaseKit

struct MockDatasource: ReadWriteDeleteDatasource {
  typealias DataType = String

  private var value: String? = "old"

  func read() async throws -> String? {
    await delay(1.0)

    guard let value = value else { throw error() }

    return value
  }

  mutating func write(_ value: String?) async throws -> String? {
    await delay(1.0)

    self.value = value

    return value
  }

  mutating func delete() async throws {
    await delay(1.0)

    guard value != nil else { throw error() }

    value = nil
  }
}

class MockRepository: ReadWriteDeleteRepository<String> {
  var dataSource = MockDatasource()

  override func pull() async throws -> String? { try await dataSource.read() }

  override func push(_ data: String?) async throws -> String? {
    if let data = data {
      return try await dataSource.write(data)
    }

    try await dataSource.delete()

    return nil
  }
}

class RepositoryObserverTests: XCTestCase, RepositoryObserver {
  let expectation = XCTestExpectation(description: "Should observe repository successfully with the correct data")

  func test() {
    let repository = MockRepository()
    repository.addObserver(self)

    Task {
      try await repository.set("new")
    }

    wait(for: [expectation], timeout: 5.0)
  }

  func repository<T>(_ repository: Repository<T>, dataDidChange data: T) where T : Decodable, T : Encodable, T : Equatable {
    XCTAssertEqual(data as? String, "new")
    expectation.fulfill()
  }

  func repositoryDidFailToSyncData<T>(_ repository: Repository<T>) where T : Decodable, T : Encodable, T : Equatable {

  }
}
