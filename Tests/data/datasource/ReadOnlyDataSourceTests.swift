import XCTest
@testable import BaseKit

class ReadOnlyDataSourceTests: XCTestCase {
  struct GoodSource: ReadOnlyDataSource {
    typealias DataType = String

    func read() async throws -> String {
      await delay(TimeInterval.random(in: 0.5...4.0))

      return "Hello, World!"
    }
  }

  struct BadSource: ReadOnlyDataSource {
    typealias DataType = String

    func read() async throws -> String {
      await delay(TimeInterval.random(in: 0.5...4.0))

      throw error()
    }
  }

  func testRead() {
    let expectation1 = XCTestExpectation(description: "Should result in success when reading from read-only good source")
    let expectation2 = XCTestExpectation(description: "Should result in failure when reading from read-only bad source")

    let goodSource = GoodSource()
    let badSource = BadSource()

    Task {
      let result = try await goodSource.read()
      XCTAssertEqual(result, "Hello, World!")
      expectation1.fulfill()
    }

    Task {
      do {
        let _ = try await badSource.read()
      }
      catch {
        expectation2.fulfill()
      }
    }

    wait(for: [expectation1, expectation2], timeout: 5.0)
  }
}
