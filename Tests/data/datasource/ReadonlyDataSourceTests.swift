import XCTest
@testable import BaseKit

class ReadonlyDatasourceTests: XCTestCase {
  struct GoodSource: ReadonlyDatasource {
    typealias DataType = String

    func read() async throws -> String {
      await delay(TimeInterval.random(in: 0.5...5.0))

      return "Hello, World!"
    }
  }

  struct BadSource: ReadonlyDatasource {
    typealias DataType = String

    func read() async throws -> String {
      await delay(TimeInterval.random(in: 0.5...5.0))

      throw error()
    }
  }

  func testRead() {
    let expectation1 = XCTestExpectation(description: "Should result in success when reading from readonly good source")
    let expectation2 = XCTestExpectation(description: "Should result in failure when reading from readonly bad source")

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
