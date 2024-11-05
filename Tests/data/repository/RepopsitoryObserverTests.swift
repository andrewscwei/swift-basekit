import XCTest
@testable import BaseKit

actor MockDatasource: ReadWriteDeleteDatasource {
  typealias DataType = String?

  private var value: String? = "old"

  func read() async throws -> String? {
    await delay(1.0)

    guard let value = value else { throw error() }

    return value
  }

  func write(_ value: String?) async throws -> String? {
    await delay(1.0)

    self.value = value

    return value
  }

  func delete() async throws {
    await delay(1.0)

    guard value != nil else { throw error() }

    value = nil
  }
}

actor MockRepository: ReadWriteDeleteRepository {
  typealias DataType = String?

  let dataSource = MockDatasource()
  let synchronizer: RepositorySynchronizer<String?> = RepositorySynchronizer()

  func pull() async throws -> String? { try await dataSource.read() }

  func push(_ data: String?) async throws -> String? {
    if let data = data {
      return try await dataSource.write(data)
    }

    try await dataSource.delete()

    return nil
  }
}

final class MockObserver: RepositoryObserver, Sendable {
  let expectation: XCTestExpectation

  func repository<T: Repository>(_ repository: T, didSyncWithData data: T.DataType) {
    XCTAssertEqual(data as? String, "new")
    expectation.fulfill()
  }

  init(expectation: XCTestExpectation) {
    self.expectation = expectation
  }
}

class RepositoryObserverTests: XCTestCase {
  let expectation = XCTestExpectation(description: "Should observe repository successfully with the correct data")

  func testDataChange() {
    let observer = MockObserver(expectation: expectation)
    let repository = MockRepository()

    Task {
      await repository.addObserver(observer)
      await repository.addObserver(observer)
      try await repository.set("new")
    }

    wait(for: [expectation], timeout: 5.0)
  }
}
