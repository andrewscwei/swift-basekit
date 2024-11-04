import XCTest
@testable import BaseKit

class ReadWriteDeleteRepositoryTests: XCTestCase {
  actor MockDatasource: ReadWriteDeleteDatasource {
    typealias DataType = String?

    private var data: String? = "old"

    func read() async throws -> String? {
      await delay(1.0)

      guard let data = data else { throw error() }

      return data
    }

    func write(_ data: String?) async throws -> String? {
      await delay(1.0)

      self.data = data

      return data
    }

    func delete() async throws {
      await delay(1.0)

      guard data != nil else { throw error() }

      data = nil
    }
  }

  final class MockRepository: ReadWriteDeleteRepository {
    typealias DataType = String?

    let dataSource = MockDatasource()
    let synchronizer = RepositorySynchronizer<String?>()

    func pull() async throws -> String? { try await dataSource.read() }

    func push(_ data: String?) async throws -> String? {
      if let data = data {
        return try await dataSource.write(data)
      }

      try await dataSource.delete()

      return nil
    }
  }

  func testDataRaces() {
    let expectation1 = XCTestExpectation(description: "Should result in success when reading from MockRepository")
    let expectation2 = XCTestExpectation(description: "Should result in success when writing to MockRepository")
    let expectation3 = XCTestExpectation(description: "Should result in success when reading from MockRepository after writing")
    let expectation4 = XCTestExpectation(description: "Should result in success when deleting from MockRepository")
    let expectation5 = XCTestExpectation(description: "Should result in success when reading from MockRepository after deleting")

    let repo = MockRepository()

    Task {
      let result = try await repo.get()
      XCTAssertEqual(result, "new")
      expectation1.fulfill()
    }

    Task {
      let result = try await repo.set("new")
      XCTAssertEqual(result, "new")
      expectation2.fulfill()
    }

    Task {
      await delay(2.0)

      let result = try await repo.get()
      XCTAssertEqual(result, "new")
      expectation3.fulfill()
    }

    Task {
      await delay(3.0)

      try await repo.delete()
      expectation4.fulfill()
    }

    Task {
      await delay(4.0)

      let result = try await repo.get()
      XCTAssertEqual(result, nil)
      expectation5.fulfill()
    }

    wait(for: [expectation1, expectation2, expectation3, expectation4, expectation5], timeout: 5.0)
  }
}
