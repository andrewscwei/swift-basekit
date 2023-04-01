import XCTest
@testable import BaseKit

class DataSourceTests: XCTestCase {
  func testReadOnlyDataSource() {
    class GoodSource: ReadOnlyDataSource {
      typealias DataType = String

      func read(completion: @escaping (Result<String, Error>) -> Void) {
        delay(1.0) {
          completion(.success("Hello, World!"))
        }
      }
    }

    class BadSource: ReadOnlyDataSource {
      typealias DataType = String

      func read(completion: @escaping (Result<String, Error>) -> Void) {
        delay(1.0) {
          completion(.failure(debugError))
        }
      }
    }

    let expectation1 = XCTestExpectation(description: "Should result in success when reading from read-only good source")
    let expectation2 = XCTestExpectation(description: "Should result in failure when reading from read-only bad source")

    let goodSource = GoodSource()
    let badSource = BadSource()

    goodSource.read { result in
      XCTAssertTrue(result.isSuccess)
      XCTAssertEqual(try? result.get(), "Hello, World!")
      expectation1.fulfill()
    }

    badSource.read { result in
      XCTAssertTrue(result.isFailure)
      expectation2.fulfill()
    }

    wait(for: [expectation1, expectation2], timeout: 5.0)
  }

  func testWriteOnlyDataSource() {
    class GoodSource: WriteOnlyDataSource {
      typealias DataType = Int

      func write(_ value: Int, completion: @escaping (Result<Int, Error>) -> Void) {
        delay(1.0) {
          completion(.success(value))
        }
      }
    }

    class BadSource: WriteOnlyDataSource {
      typealias DataType = Int

      func write(_ value: Int, completion: @escaping (Result<Int, Error>) -> Void) {
        delay(1.0) {
          completion(.failure(debugError))
        }
      }
    }

    let expectation1 = XCTestExpectation(description: "Should result in success when writing to write-only good source")
    let expectation2 = XCTestExpectation(description: "Should result in success when writing to write-only good source again")
    let expectation3 = XCTestExpectation(description: "Should result in failure when writing to write-only bad source")

    let goodSource = GoodSource()
    let badSource = BadSource()

    goodSource.write(1) { result in
      XCTAssertTrue(result.isSuccess)
      XCTAssertEqual(try? result.get(), 1)
      expectation1.fulfill()
    }

    goodSource.write(2) { result in
      XCTAssertTrue(result.isSuccess)
      XCTAssertEqual(try? result.get(), 2)
      expectation2.fulfill()
    }

    badSource.write(1) { result in
      XCTAssertTrue(result.isFailure)
      expectation3.fulfill()
    }

    wait(for: [expectation1, expectation2, expectation3], timeout: 5.0)
  }

  func testReadWriteDataSource() {
    class GoodSource: ReadWriteDataSource {
      typealias DataType = String

      func read(completion: @escaping (Result<String, Error>) -> Void) {
        delay(1.0) {
          completion(.success("Hello, World!"))
        }
      }

      func write(_ value: String, completion: @escaping (Result<String, Error>) -> Void) {
        delay(1.0) {
          completion(.success(value))
        }
      }
    }

    class BadSource: ReadWriteDataSource {
      typealias DataType = String

      func read(completion: @escaping (Result<String, Error>) -> Void) {
        delay(1.0) {
          completion(.failure(debugError))
        }
      }

      func write(_ value: String, completion: @escaping (Result<String, Error>) -> Void) {
        delay(1.0) {
          completion(.failure(debugError))
        }
      }
    }

    let expectation1 = XCTestExpectation(description: "Should result in success when reading from read/write good source")
    let expectation2 = XCTestExpectation(description: "Should result in success when writing to read/write good source")
    let expectation3 = XCTestExpectation(description: "Should result in success when writing to read/write good source again")
    let expectation4 = XCTestExpectation(description: "Should result in failure when reading from read/write bad source")
    let expectation5 = XCTestExpectation(description: "Should result in failure when writing to read/write bad source")

    let goodSource = GoodSource()
    let badSource = BadSource()

    goodSource.read { result in
      XCTAssertTrue(result.isSuccess)
      XCTAssertEqual(try? result.get(), "Hello, World!")
      expectation1.fulfill()
    }

    goodSource.write("foo") { result in
      XCTAssertTrue(result.isSuccess)
      XCTAssertEqual(try? result.get(), "foo")
      expectation2.fulfill()
    }

    goodSource.write("bar") { result in
      XCTAssertTrue(result.isSuccess)
      XCTAssertEqual(try? result.get(), "bar")
      expectation3.fulfill()
    }

    badSource.read { result in
      XCTAssertTrue(result.isFailure)
      expectation4.fulfill()
    }

    badSource.write("bar") { result in
      XCTAssertTrue(result.isFailure)
      expectation5.fulfill()
    }

    wait(for: [expectation1, expectation2, expectation3, expectation4, expectation5], timeout: 5.0)
  }

  func testWriteDeleteDataSource() {
    class GoodSource: WriteDeleteDataSource {
      typealias DataType = Int

      func write(_ value: Int, completion: @escaping (Result<Int, Error>) -> Void) {
        delay(1.0) {
          completion(.success(value))
        }
      }

      func delete(completion: @escaping (Result<Void, Error>) -> Void) {
        delay(1.0) {
          completion(.success)
        }
      }
    }

    class BadSource: WriteDeleteDataSource {
      typealias DataType = Int

      func write(_ value: Int, completion: @escaping (Result<Int, Error>) -> Void) {
        delay(1.0) {
          completion(.failure(debugError))
        }
      }

      func delete(completion: @escaping (Result<Void, Error>) -> Void) {
        delay(1.0) {
          completion(.failure(debugError))
        }
      }
    }

    let expectation1 = XCTestExpectation(description: "Should result in success when writing to write/delete good source")
    let expectation2 = XCTestExpectation(description: "Should result in success when deleting from write/delete good source")
    let expectation3 = XCTestExpectation(description: "Should result in failure when writing to write/delete bad source")
    let expectation4 = XCTestExpectation(description: "Should result in failure when deleting from write/delete bad source")

    let goodSource = GoodSource()
    let badSource = BadSource()

    goodSource.write(1) { result in
      XCTAssertTrue(result.isSuccess)
      XCTAssertEqual(try? result.get(), 1)
      expectation1.fulfill()
    }

    goodSource.delete { result in
      XCTAssertTrue(result.isSuccess)
      expectation2.fulfill()
    }

    badSource.write(1) { result in
      XCTAssertTrue(result.isFailure)
      expectation3.fulfill()
    }

    badSource.delete { result in
      XCTAssertTrue(result.isFailure)
      expectation4.fulfill()
    }

    wait(for: [expectation1, expectation2, expectation3, expectation4], timeout: 5.0)
  }

  func testReadWriteDeleteDataSource() {
    class GoodSource: ReadWriteDeleteDataSource {
      typealias DataType = Int

      func read(completion: @escaping (Result<Int?, Error>) -> Void) {
        delay(1.0) {
          completion(.success(1))
        }
      }

      func write(_ value: Int, completion: @escaping (Result<Int, Error>) -> Void) {
        delay(1.0) {
          completion(.success(value))
        }
      }

      func delete(completion: @escaping (Result<Void, Error>) -> Void) {
        delay(1.0) {
          completion(.success)
        }
      }
    }

    class BadSource: ReadWriteDeleteDataSource {
      typealias DataType = Int

      func read(completion: @escaping (Result<Int?, Error>) -> Void) {
        delay(1.0) {
          completion(.failure(debugError))
        }
      }

      func write(_ value: Int, completion: @escaping (Result<Int, Error>) -> Void) {
        delay(1.0) {
          completion(.failure(debugError))
        }
      }

      func delete(completion: @escaping (Result<Void, Error>) -> Void) {
        delay(1.0) {
          completion(.failure(debugError))
        }
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

    goodSource.read { result in
      XCTAssertTrue(result.isSuccess)
      XCTAssertEqual(try? result.get(), 1)
      expectation1.fulfill()
    }

    goodSource.write(1) { result in
      XCTAssertTrue(result.isSuccess)
      XCTAssertEqual(try? result.get(), 1)
      expectation2.fulfill()
    }

    goodSource.delete { result in
      XCTAssertTrue(result.isSuccess)
      expectation3.fulfill()
    }

    badSource.read { result in
      XCTAssertTrue(result.isFailure)
      expectation4.fulfill()
    }

    badSource.write(1) { result in
      XCTAssertTrue(result.isFailure)
      expectation5.fulfill()
    }

    badSource.delete { result in
      XCTAssertTrue(result.isFailure)
      expectation6.fulfill()
    }

    wait(for: [expectation1, expectation2, expectation3, expectation4, expectation5, expectation6], timeout: 5.0)
  }
}
