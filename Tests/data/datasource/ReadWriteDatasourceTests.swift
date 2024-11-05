import XCTest
@testable import BaseKit

class ReadWriteDatasourceTests: XCTestCase {
  struct GoodSource: ReadWriteDatasource {
    typealias DataType = String

    func read() async throws -> String {
      await delay(TimeInterval.random(in: 0.5...4.0))

      return "Hello, World!"
    }

    func write(_ value: String) async throws -> String {
      await delay(TimeInterval.random(in: 0.5...4.0))

      return value
    }
  }

  struct BadSource: ReadWriteDatasource {
    typealias DataType = String

    func read() async throws -> String {
      await delay(TimeInterval.random(in: 0.5...4.0))

      throw error()
    }

    func write(_ value: String) async throws -> String {
      await delay(TimeInterval.random(in: 0.5...4.0))

      throw error()
    }
  }

  func testReadWrite() {
    let expectation1 = XCTestExpectation(description: "Should result in success when reading from read/write good source")
    let expectation2 = XCTestExpectation(description: "Should result in success when writing to read/write good source")
    let expectation3 = XCTestExpectation(description: "Should result in success when writing to read/write good source again")
    let expectation4 = XCTestExpectation(description: "Should result in failure when reading from read/write bad source")
    let expectation5 = XCTestExpectation(description: "Should result in failure when writing to read/write bad source")

    let goodSource = GoodSource()
    let badSource = BadSource()

    Task {
      let result = try await goodSource.read()
      XCTAssertEqual(result, "Hello, World!")
      expectation1.fulfill()
    }

    Task {
      let result = try await goodSource.write("foo")
      XCTAssertEqual(result, "foo")
      expectation2.fulfill()
    }

    Task {
      let result = try await goodSource.write("bar")
      XCTAssertEqual(result, "bar")
      expectation3.fulfill()
    }

    Task {
      do {
        let _ = try await badSource.read()
      }
      catch {
        expectation4.fulfill()
      }
    }

    Task {
      do {
        let _ = try await badSource.write("bar")
      }
      catch {
        expectation5.fulfill()
      }
    }

    wait(for: [expectation1, expectation2, expectation3, expectation4, expectation5], timeout: 5.0)
  }
}
