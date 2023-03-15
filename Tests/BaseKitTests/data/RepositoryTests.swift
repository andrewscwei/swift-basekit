import XCTest
@testable import BaseKit

class MockReadonlyDataSource: ReadOnlyDataSource {
  typealias DataType = String

  private var value: DataType = "default-value"

  func updateValue(newValue: DataType) {
    value = newValue
  }

  func read(completion: @escaping (Result<DataType, Error>) -> Void) {
    delay(1.0) {
      completion(.success(self.value))
    }
  }
}

class MockReadOnlyRepository: ReadOnlyRepository<String> {
  override var debugMode: Bool { true }

  let dataSource = MockReadonlyDataSource()

  override func pull(completion: @escaping (Result<String, Error>) -> Void = { _ in }) {
    dataSource.read(completion: completion)
  }
}

class MockReadWriteDataSource: ReadWriteDataSource {
  typealias DataType = String

  private var value: DataType = "default-value"

  func read(completion: @escaping (Result<DataType, Error>) -> Void) {
    delay(1.0) {
      completion(.success(self.value))
    }
  }

  func write(_ value: String, completion: @escaping (Result<String, Error>) -> Void) {
    delay(1.0) {
      self.value = value
      completion(.success(value))
    }
  }
}

class MockReadWriteRepository: ReadWriteRepository<String> {
  override var debugMode: Bool { true }

  let dataSource = MockReadWriteDataSource()

  override func pull(completion: @escaping (Result<String, Error>) -> Void = { _ in }) {
    dataSource.read(completion: completion)
  }

  override func push(_ current: String, completion: @escaping (Result<String, Error>) -> Void = { _ in }) {
    dataSource.write(current, completion: completion)
  }
}

class MockReadWriteDeleteDataSource: ReadWriteDeleteDataSource {
  typealias DataType = String

  private var value: String? = "default-value"

  func read(completion: @escaping (Result<String?, Error>) -> Void) {
    delay(1.0) {
      if let value = self.value {
        completion(.success(value))
      }
      else {
        completion(.failure(DataSourceError.unexpectedNilValue))
      }
    }
  }

  func write(_ value: String, completion: @escaping (Result<String, Error>) -> Void) {
    delay(1.0) {
      self.value = value
      completion(.success(value))
    }
  }

  func delete(completion: @escaping (Result<Void, Error>) -> Void) {
    delay(1.0) {
      if let _ = self.value {
        self.value = nil
        completion(.success)
      }
      else {
        completion(.failure(DataSourceError.unexpectedNilValue))
      }
    }
  }
}

class MockReadWriteDeleteRepository: ReadWriteDeleteRepository<String> {
  let dataSource = MockReadWriteDeleteDataSource()

  override func pull(completion: @escaping (Result<String?, Error>) -> Void = { _ in }) {
    dataSource.read { result in
      completion(result)
    }
  }

  override func push(_ current: String?, completion: @escaping (Result<String?, Error>) -> Void = { _ in }) {
    if let current = current {
      dataSource.write(current) { result in
        completion(result.map { $0 as String? })
      }
    }
    else {
      dataSource.delete { result in
        completion(result.map { _ in nil })
      }
    }
  }
}

class MockRepositoryObserver: RepositoryObserver {
  func repository<T>(_ repository: Repository<T>, dataDidChange data: T) where T : Decodable, T : Encodable, T : Equatable {
    switch repository {
    case is MockReadOnlyRepository:
      print("MockReadOnlyRepository changed")
      break
    case is MockReadWriteRepository:
      print("MockReadWriteRepository changed")
      break
    case is MockReadWriteDeleteRepository:
      print("MockReadWriteDeleteRepository changed")
      break
    default:
      break
    }
  }

  func repositoryDidFailToSyncData<T>(_ repository: Repository<T>) where T : Decodable, T : Encodable, T : Equatable {
    
  }
}

class RepositoryTests: XCTestCase {
  func testReadOnlyRepository() {
    let expectation1 = XCTestExpectation(description: "Should result in success when reading from MockReadOnlyRepository")
    let expectation2 = XCTestExpectation(description: "Should result in success when reading from MockReadOnlyRepository immediately again")
    let expectation3 = XCTestExpectation(description: "Should result in success when reading from MockReadOnlyRepository immediately yet again after updating the stored value")

    let repo = MockReadOnlyRepository()

    repo.get { result in
      XCTAssertTrue(result.isSuccess)
      XCTAssertEqual(try? result.get(), "updated-value")
      expectation1.fulfill()
    }

    repo.get { result in
      XCTAssertTrue(result.isSuccess)
      XCTAssertEqual(try? result.get(), "updated-value")
      expectation2.fulfill()
    }

    repo.dataSource.updateValue(newValue: "updated-value")

    repo.get { result in
      XCTAssertTrue(result.isSuccess)
      XCTAssertEqual(try? result.get(), "updated-value")
      expectation3.fulfill()
    }

    wait(for: [expectation1, expectation2, expectation3], timeout: 5.0)
  }

  func testReadWriteRepositories() {
    let expectation1 = XCTestExpectation()
    let expectation2 = XCTestExpectation()
    let expectation3 = XCTestExpectation()

    let repo = MockReadWriteRepository()

    repo.get { result in
      XCTAssertEqual(try? result.get(), "updated-value")
      expectation1.fulfill()
    }

    XCTAssertEqual(repo.getCurrent(), .notSynced)

    repo.set("updated-value") { result in
      XCTAssertEqual(try? result.get(), "updated-value")
      expectation2.fulfill()
    }

    repo.get { result in
      XCTAssertEqual(try? result.get(), "updated-value")
      expectation3.fulfill()
    }

    wait(for: [expectation1, expectation2, expectation3], timeout: 5.0)
  }

  func testReadWriteDeleteRepositories() {
    let expectation1 = XCTestExpectation()
    let expectation2 = XCTestExpectation()
    let expectation3 = XCTestExpectation()
    let expectation4 = XCTestExpectation()
    let expectation5 = XCTestExpectation()

    let repo = MockReadWriteDeleteRepository()

    repo.get { result in
      XCTAssertEqual(try? result.get(), "updated-value")
      expectation1.fulfill()
    }

    repo.set("updated-value") { result in
      XCTAssertEqual(try? result.get(), "updated-value")
      expectation2.fulfill()
    }

    delay(2.0) {
      repo.get { result in
        XCTAssertEqual(try? result.get(), "updated-value")
        expectation3.fulfill()
      }
    }

    delay(3.0) {
      repo.delete { result in
        XCTAssertTrue(result.isSuccess)
        expectation4.fulfill()
      }
    }

    delay(4.0) {
      repo.get { result in
        XCTAssertEqual(try? result.get(), nil)
        expectation5.fulfill()
      }
    }

    wait(for: [expectation1, expectation2, expectation3, expectation4, expectation5], timeout: 5.0)
  }

  func testRepositoryObserver() {
    let expectation1 = XCTestExpectation()
    let expectation2 = XCTestExpectation()
    let expectation3 = XCTestExpectation()

    let observer = MockRepositoryObserver()
    let readOnlyRepository = MockReadOnlyRepository()
    let readWriteRepository = MockReadWriteRepository()
    let readWriteDeleteRepository = MockReadWriteDeleteRepository()

    readOnlyRepository.addObserver(observer)
    readWriteRepository.addObserver(observer)
    readWriteDeleteRepository.addObserver(observer)

    readOnlyRepository.get { result in
      expectation1.fulfill()
    }

    readWriteRepository.set("rw-value") { result in
      expectation2.fulfill()
    }

    readWriteDeleteRepository.set("rwd-value") { result in
      expectation3.fulfill()
    }

    wait(for: [expectation1, expectation2, expectation3], timeout: 5.0)
  }
}
