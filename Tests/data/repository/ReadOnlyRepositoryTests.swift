import XCTest
@testable import BaseKit

class ReadOnlyRepositoryTests: XCTestCase {
  actor MockDataSource: ReadOnlyDataSource {
    typealias DataType = String

    private var data: DataType = "old"

    func updateValue(_ newValue: DataType) async throws {
      await delay(0.5)

      data = newValue
    }

    func read() async throws -> String {
      await delay(1.0)

      return data
    }
  }

  actor MockRepository: ReadOnlyRepository {
    typealias DataType = String

    let synchronizer: RepositorySynchronizer<String> = .init()
    var dataSource = MockDataSource()

    func updateData(_ newValue: String) async {
      try? await dataSource.updateValue(newValue)
    }

    func pull() async throws -> String { try await dataSource.read() }
  }

  func testDataRace() {
    let expectation1 = XCTestExpectation(description: "Should result in success when reading from MockRepository")
    let expectation2 = XCTestExpectation(description: "Should result in success when reading from MockRepository immediately again")
    let expectation3 = XCTestExpectation(description: "Should result in success when reading from MockRepository immediately yet again after updating the stored data")

    let repo = MockRepository()

    Task {
      let result = try await repo.get()
      XCTAssertEqual(result, "new")
      expectation1.fulfill()
    }

    Task {
      let result = try await repo.get()
      XCTAssertEqual(result, "new")
      expectation2.fulfill()
    }

    Task {
      try await repo.dataSource.updateValue("new")
    }

    Task {
      await delay(0.5)

      let result = try await repo.get()
      XCTAssertEqual(result, "new")
      expectation3.fulfill()
    }

    wait(for: [expectation1, expectation2, expectation3], timeout: 5.0)
  }
}
