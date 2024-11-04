import XCTest
@testable import BaseKit

class ReadWriteDeleteDatasourceTests: XCTestCase {
  class GoodSource: ReadWriteDeleteDatasource {
    typealias DataType = Int

    func read() async throws -> Int? {
      await delay(TimeInterval.random(in: 0.5...5.0))

      return 1
    }

    func write(_ value: Int?) async throws -> Int? {
      await delay(TimeInterval.random(in: 0.5...5.0))

      return value
    }

    func delete() async throws {
      await delay(TimeInterval.random(in: 0.5...5.0))
    }
  }

  class BadSource: ReadWriteDeleteDatasource {
    typealias DataType = Int

    func read() async throws -> Int? {
      await delay(TimeInterval.random(in: 0.5...5.0))

      throw error()
    }

    func write(_ value: Int?) async throws -> Int? {
      await delay(TimeInterval.random(in: 0.5...5.0))

      throw error()
    }

    func delete() async throws {
      await delay(TimeInterval.random(in: 0.5...5.0))

      throw error()
    }
  }

  func test() {
    let expectation1 = XCTestExpectation(description: "Should result in success when reading from read/write/delete good source")
    let expectation2 = XCTestExpectation(description: "Should result in success when writing to read/write/delete good source")
    let expectation3 = XCTestExpectation(description: "Should result in success when deleting from read/write/delete good source")
    let expectation4 = XCTestExpectation(description: "Should result in failure when reading from read/write/delete bad source")
    let expectation5 = XCTestExpectation(description: "Should result in failure when writing to read/write/delete bad source")
    let expectation6 = XCTestExpectation(description: "Should result in failure when deleting from read/write/delete bad source")

    let goodSource = GoodSource()
    let badSource = BadSource()

    Task {
      let result = try await goodSource.read()
      XCTAssertEqual(result, 1)
      expectation1.fulfill()
    }

    Task {
      let result = try await goodSource.write(1)
      XCTAssertEqual(result, 1)
      expectation2.fulfill()
    }

    Task {
      try await goodSource.delete()
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
        let _ = try await badSource.write(1)
      }
      catch {
        expectation5.fulfill()
      }
    }

    Task {
      do {
        try await badSource.delete()
      }
      catch {
        expectation6.fulfill()
      }
    }

    wait(for: [expectation1, expectation2, expectation3, expectation4, expectation5, expectation6], timeout: 5.0)
  }
}
