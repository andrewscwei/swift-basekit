import XCTest
@testable import BaseKit

class ReadWriteRepositoryTests: XCTestCase {
  struct MockDataSource: ReadWriteDataSource {
    typealias DataType = String

    private var data: DataType = "old"

    func read() async throws -> String {
      await delay(1.0)

      return data
    }

    mutating func write(_ data: String) async throws -> String {
      await delay(1.0)

      self.data = data

      return data
    }
  }

  class MockRepository: ReadWriteRepository<String> {
    var dataSource = MockDataSource()

    override func pull() async throws -> String {
      return try await dataSource.read()
    }

    override func push(_ data: String) async throws -> String {
      return try await dataSource.write(data)
    }
  }

  func test() {
    let expectation1 = XCTestExpectation(description: "Should result in success when reading from MockRepository")
    let expectation2 = XCTestExpectation(description: "Should result in success when writing to MockRepository")
    let expectation3 = XCTestExpectation(description: "Should result in success when reading from MockRepository after writing")

    let repo = MockRepository()

    Task {
      let result = try await repo.get()
      XCTAssertEqual(result, "new")
      expectation1.fulfill()
    }

    Task {
      let state = await repo.getState()
      XCTAssertEqual(state, .initial)
    }

    Task {
      let result = try await repo.set("new")
      XCTAssertEqual(result, "new")
      expectation2.fulfill()
    }

    Task {
      let result = try await repo.get()
      XCTAssertEqual(result, "new")
      expectation3.fulfill()
    }

    wait(for: [expectation1, expectation2, expectation3], timeout: 5.0)
  }
}
