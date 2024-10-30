import XCTest
@testable import BaseKit

class MockReadonlyDataSource: ReadOnlyDataSource {
  typealias DataType = String

  private var value: DataType = "default-value"

  func updateValue(newValue: DataType) {
    value = newValue
  }

  @discardableResult func read() async throws -> String {
    await delay(1.0)

    return self.value
  }
}

class MockReadOnlyRepository: ReadOnlyRepository<String> {
  let dataSource = MockReadonlyDataSource()

  override func pull(completion: @escaping (Result<String, Error>) -> Void = { _ in }) {
    Task {
      do {
        let data = try await self.dataSource.read()

        completion(.success(data))
      }
      catch {
        completion(.failure(error))
      }
    }
  }
}

class MockReadWriteDataSource: ReadWriteDataSource {
  typealias DataType = String

  private var value: DataType = "default-value"

  @discardableResult func read() async throws -> String {
    await delay(1.0)

    return self.value
  }

  @discardableResult func write(_ value: String) async throws -> String {
    await delay(1.0)

    self.value = value

    return value
  }
}

class MockReadWriteRepository: ReadWriteRepository<String> {
  override var debugMode: Bool { true }

  let dataSource = MockReadWriteDataSource()

  override func pull(completion: @escaping (Result<String, Error>) -> Void = { _ in }) {
    Task {
      do {
        let data = try await self.dataSource.read()
        completion(.success(data))
      }
      catch {
        completion(.failure(error))
      }
    }
  }

  override func push(_ current: String, completion: @escaping (Result<String, Error>) -> Void = { _ in }) {
    Task {
      do {
        let data = try await self.dataSource.write(current)
        completion(.success(data))
      }
      catch {
        completion(.failure(error))
      }
    }
  }
}

class MockReadWriteDeleteDataSource: ReadWriteDeleteDataSource {
  typealias DataType = String

  private var value: String? = "default-value"

  @discardableResult func read() async throws -> String? {
    await delay(1.0)

    if let value = self.value {
      return value
    }
    else {
      throw error()
    }
  }

  @discardableResult func write(_ value: String) async throws -> String {
    await delay(1.0)
    self.value = value

    return value
  }

  func delete() async throws {
    await delay(1.0)

    if let _ = self.value {
      self.value = nil
    }
    else {
      throw error()
    }
  }
}

class MockReadWriteDeleteRepository: ReadWriteDeleteRepository<String> {
  let dataSource = MockReadWriteDeleteDataSource()

  override func pull(completion: @escaping (Result<String?, Error>) -> Void = { _ in }) {
    Task {
      do {
        let data = try await self.dataSource.read()
        completion(.success(data))
      }
      catch {
        completion(.failure(error))
      }
    }
  }

  override func push(_ current: String?, completion: @escaping (Result<String?, Error>) -> Void = { _ in }) {
    Task {
      do {
        if let current = current {
          let data = try await self.dataSource.write(current)

          completion(.success(data))
        }
        else {
          try await self.dataSource.delete()

          completion(.success(nil))
        }
      }
      catch {
        completion(.failure(error))
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
    let expectation1 = XCTestExpectation(description: "Should result in success when reading from MockReadWriteRepository")
    let expectation2 = XCTestExpectation(description: "Should result in success when writing to MockReadWriteRepository")
    let expectation3 = XCTestExpectation(description: "Should result in success when reading from MockReadWriteRepository after writing")

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
    let expectation1 = XCTestExpectation(description: "Should result in success when reading from MockReadWriteDeleteRepository")
    let expectation2 = XCTestExpectation(description: "Should result in success when writing to MockReadWriteDeleteRepository")
    let expectation3 = XCTestExpectation(description: "Should result in success when reading from MockReadWriteDeleteRepository after writing")
    let expectation4 = XCTestExpectation(description: "Should result in success when deleting from MockReadWriteDeleteRepository")
    let expectation5 = XCTestExpectation(description: "Should result in success when reading from MockReadWriteDeleteRepository after deleting")

    let repo = MockReadWriteDeleteRepository()

    repo.get { result in
      XCTAssertEqual(try? result.get(), "updated-value")
      expectation1.fulfill()
    }

    repo.set("updated-value") { result in
      XCTAssertEqual(try? result.get(), "updated-value")
      expectation2.fulfill()
    }

    Task {
      await delay(2.0)

      repo.get { result in
        XCTAssertEqual(try? result.get(), "updated-value")
        expectation3.fulfill()
      }
    }

    Task {
      await delay(3.0)

      repo.delete { result in
        XCTAssertTrue(result.isSuccess)
        expectation4.fulfill()
      }
    }

    Task {
      await delay(4.0)

      repo.get { result in
        XCTAssertEqual(try? result.get(), nil)
        expectation5.fulfill()
      }
    }

    wait(for: [expectation1, expectation2, expectation3, expectation4, expectation5], timeout: 5.0)
  }

  func testRepositoryObserver() {
    let expectation1 = XCTestExpectation(description: "Should result in success when reading from MockReadOnlyRepository")
    let expectation2 = XCTestExpectation(description: "Should result in success when writing to MockReadWriteRepository")
    let expectation3 = XCTestExpectation(description: "Should result in success when writing to MockReadWriteDeleteRepository")

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
