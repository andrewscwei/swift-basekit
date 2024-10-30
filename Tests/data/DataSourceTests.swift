import XCTest
@testable import BaseKit

class DataSourceTests: XCTestCase {
  func testReadOnlyDataSource() {
    class GoodSource: ReadOnlyDataSource {
      typealias DataType = String

      @discardableResult func read() async throws -> String {
        await delay(TimeInterval.random(in: 0.5...5.0))

        return "Hello, World!"
      }
    }

    class BadSource: ReadOnlyDataSource {
      typealias DataType = String

      @discardableResult func read() async throws -> String {
        await delay(TimeInterval.random(in: 0.5...5.0))

        throw error()
      }
    }

    let expectation1 = XCTestExpectation(description: "Should result in success when reading from read-only good source")
    let expectation2 = XCTestExpectation(description: "Should result in failure when reading from read-only bad source")

    let goodSource = GoodSource()
    let badSource = BadSource()

    Task.detached {
      let result = try await goodSource.read()
      XCTAssertEqual(result, "Hello, World!")
      expectation1.fulfill()
    }

    Task.detached {
      do {
        try await badSource.read()
      }
      catch {
        expectation2.fulfill()
      }
    }

    wait(for: [expectation1, expectation2], timeout: 5.0)
  }

  func testWriteOnlyDataSource() {
    class GoodSource: WriteOnlyDataSource {
      typealias DataType = Int

      @discardableResult func write(_ value: Int) async throws -> Int {
        await delay(TimeInterval.random(in: 0.5...5.0))

        return value
      }
    }

    class BadSource: WriteOnlyDataSource {
      typealias DataType = Int

      @discardableResult func write(_ value: Int) async throws -> Int {
        await delay(TimeInterval.random(in: 0.5...5.0))

        throw error()
      }
    }

    let expectation1 = XCTestExpectation(description: "Should result in success when writing to write-only good source")
    let expectation2 = XCTestExpectation(description: "Should result in success when writing to write-only good source again")
    let expectation3 = XCTestExpectation(description: "Should result in failure when writing to write-only bad source")

    let goodSource = GoodSource()
    let badSource = BadSource()

    Task.detached {
      let result = try await goodSource.write(1)
      XCTAssertEqual(result, 1)
      expectation1.fulfill()
    }

    Task.detached {
      let result = try await goodSource.write(2)
      XCTAssertEqual(result, 2)
      expectation2.fulfill()
    }

    Task.detached {
      do {
        try await badSource.write(1)
      }
      catch {
        expectation3.fulfill()
      }
    }

    wait(for: [expectation1, expectation2, expectation3], timeout: 5.0)
  }

  func testReadWriteDataSource() {
    class GoodSource: ReadWriteDataSource {
      typealias DataType = String

      @discardableResult func read() async throws -> String {
        await delay(TimeInterval.random(in: 0.5...5.0))

        return "Hello, World!"
      }

      @discardableResult func write(_ value: String) async throws -> String {
        await delay(TimeInterval.random(in: 0.5...5.0))

        return value
      }
    }

    class BadSource: ReadWriteDataSource {
      typealias DataType = String

      @discardableResult func read() async throws -> String {
        await delay(TimeInterval.random(in: 0.5...5.0))

        throw error()
      }

      @discardableResult func write(_ value: String) async throws -> String {
        await delay(TimeInterval.random(in: 0.5...5.0))

        throw error()
      }
    }

    let expectation1 = XCTestExpectation(description: "Should result in success when reading from read/write good source")
    let expectation2 = XCTestExpectation(description: "Should result in success when writing to read/write good source")
    let expectation3 = XCTestExpectation(description: "Should result in success when writing to read/write good source again")
    let expectation4 = XCTestExpectation(description: "Should result in failure when reading from read/write bad source")
    let expectation5 = XCTestExpectation(description: "Should result in failure when writing to read/write bad source")

    let goodSource = GoodSource()
    let badSource = BadSource()

    Task.detached {
      let result = try await goodSource.read()
      XCTAssertEqual(result, "Hello, World!")
      expectation1.fulfill()
    }

    Task.detached {
      let result = try await goodSource.write("foo")
      XCTAssertEqual(result, "foo")
      expectation2.fulfill()
    }

    Task.detached {
      let result = try await goodSource.write("bar")
      XCTAssertEqual(result, "bar")
      expectation3.fulfill()
    }

    Task.detached {
      do {
        try await badSource.read()
      }
      catch {
        expectation4.fulfill()
      }
    }

    Task.detached {
      do {
        try await badSource.write("bar")
      }
      catch {
        expectation5.fulfill()
      }
    }

    wait(for: [expectation1, expectation2, expectation3, expectation4, expectation5], timeout: 5.0)
  }

  func testWriteDeleteDataSource() {
    class GoodSource: WriteDeleteDataSource {
      typealias DataType = Int

      @discardableResult func write(_ value: Int) async throws -> Int {
        await delay(TimeInterval.random(in: 0.5...5.0))

        return value
      }

      func delete() async throws {
        await delay(TimeInterval.random(in: 0.5...5.0))
      }
    }

    class BadSource: WriteDeleteDataSource {
      typealias DataType = Int

      @discardableResult func write(_ value: Int) async throws -> Int {
        await delay(TimeInterval.random(in: 0.5...5.0))

        throw error()
      }

      func delete() async throws {
        await delay(TimeInterval.random(in: 0.5...5.0))

        throw error()
      }
    }

    let expectation1 = XCTestExpectation(description: "Should result in success when writing to write/delete good source")
    let expectation2 = XCTestExpectation(description: "Should result in success when deleting from write/delete good source")
    let expectation3 = XCTestExpectation(description: "Should result in failure when writing to write/delete bad source")
    let expectation4 = XCTestExpectation(description: "Should result in failure when deleting from write/delete bad source")

    let goodSource = GoodSource()
    let badSource = BadSource()

    Task.detached {
      let result = try await goodSource.write(1)
      XCTAssertEqual(result, 1)
      expectation1.fulfill()
    }

    Task.detached {
      try await goodSource.delete()
      expectation2.fulfill()
    }

    Task.detached {
      do {
        try await badSource.write(1)
      }
      catch {
        expectation3.fulfill()
      }
    }

    Task.detached {
      do {
        try await badSource.delete()
      }
      catch {
        expectation4.fulfill()
      }
    }

    wait(for: [expectation1, expectation2, expectation3, expectation4], timeout: 5.0)
  }

  func testReadWriteDeleteDataSource() {
    class GoodSource: ReadWriteDeleteDataSource {
      typealias DataType = Int

      @discardableResult func read() async throws -> Int? {
        await delay(TimeInterval.random(in: 0.5...5.0))

        return 1
      }

      @discardableResult func write(_ value: Int) async throws -> Int {
        await delay(TimeInterval.random(in: 0.5...5.0))

        return value
      }

      func delete() async throws {
        await delay(TimeInterval.random(in: 0.5...5.0))
      }
    }

    class BadSource: ReadWriteDeleteDataSource {
      typealias DataType = Int

      @discardableResult func read() async throws -> Int? {
        await delay(TimeInterval.random(in: 0.5...5.0))

        throw error()
      }

      @discardableResult func write(_ value: Int) async throws -> Int {
        await delay(TimeInterval.random(in: 0.5...5.0))

        throw error()
      }

      func delete() async throws {
        await delay(TimeInterval.random(in: 0.5...5.0))

        throw error()
      }
    }

    let expectation1 = XCTestExpectation(description: "Should result in success when reading from read/write/delete good source")
    let expectation2 = XCTestExpectation(description: "Should result in success when writing to read/write/delete good source")
    let expectation3 = XCTestExpectation(description: "Should result in success when deleting from read/write/delete good source")
    let expectation4 = XCTestExpectation(description: "Should result in failure when reading from read/write/delete bad source")
    let expectation5 = XCTestExpectation(description: "Should result in failure when writing to read/write/delete bad source")
    let expectation6 = XCTestExpectation(description: "Should result in failure when deleting from read/write/delete bad source")

    let goodSource = GoodSource()
    let badSource = BadSource()

    Task.detached {
      let result = try await goodSource.read()
      XCTAssertEqual(result, 1)
      expectation1.fulfill()
    }

    Task.detached {
      let result = try await goodSource.write(1)
      XCTAssertEqual(result, 1)
      expectation2.fulfill()
    }

    Task.detached {
      try await goodSource.delete()
      expectation3.fulfill()
    }

    Task.detached {
      do {
        try await badSource.read()
      }
      catch {
        expectation4.fulfill()
      }
    }

    Task.detached {
      do {
        try await badSource.write(1)
      }
      catch {
        expectation5.fulfill()
      }
    }

    Task.detached {
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
