import XCTest
@testable import BaseKit

struct MockReadonlyDataSource: ReadOnlyDataSource {
  typealias DataType = String

  private var value: DataType = "old"

  mutating func updateValue(_ newValue: DataType) async throws {
    value = newValue
  }

  func read() async throws -> String {
    await delay(1.0)

    return value
  }
}

class MockReadOnlyRepository: ReadOnlyRepository<String> {
  var dataSource = MockReadonlyDataSource()

  override func pull() async throws -> String { try await dataSource.read() }
}

struct MockReadWriteDataSource: ReadWriteDataSource {
  typealias DataType = String

  private var value: DataType = "old"

  func read() async throws -> String {
    await delay(1.0)

    return value
  }

  mutating func write(_ value: String) async throws -> String {
    await delay(1.0)

    self.value = value

    return value
  }
}

class MockReadWriteRepository: ReadWriteRepository<String> {
  override var debugMode: Bool { true }

  var dataSource = MockReadWriteDataSource()

  override func pull() async throws -> String {
    return try await dataSource.read()
  }

  override func push(_ data: String) async throws -> String {
    return try await dataSource.write(data)
  }
}

struct MockReadWriteDeleteDataSource: ReadWriteDeleteDataSource {
  typealias DataType = String

  private var value: String? = "old"

  func read() async throws -> String? {
    await delay(1.0)

    guard let value = value else { throw error() }

    return value
  }

  mutating func write(_ value: String?) async throws -> String? {
    await delay(1.0)

    self.value = value

    return value
  }

  mutating func delete() async throws {
    await delay(1.0)

    guard value != nil else { throw error() }

    value = nil
  }
}

class MockReadWriteDeleteRepository: ReadWriteDeleteRepository<String> {
  var dataSource = MockReadWriteDeleteDataSource()

  override func pull() async throws -> String? { try await dataSource.read() }

  override func push(_ data: String?) async throws -> String? {
    if let data = data {
      return try await dataSource.write(data)
    }

    try await dataSource.delete()

    return nil
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
      let result = try await repo.get()
      XCTAssertEqual(result, "new")
      expectation3.fulfill()
    }

    wait(for: [expectation1, expectation2, expectation3], timeout: 5.0)
  }

  func testReadWriteRepositories() {
    let expectation1 = XCTestExpectation(description: "Should result in success when reading from MockReadWriteRepository")
    let expectation2 = XCTestExpectation(description: "Should result in success when writing to MockReadWriteRepository")
    let expectation3 = XCTestExpectation(description: "Should result in success when reading from MockReadWriteRepository after writing")

    let repo = MockReadWriteRepository()

    Task {
      let result = try await repo.get()
      XCTAssertEqual(result, "new")
      expectation1.fulfill()
    }

    XCTAssertEqual(repo.getState(), .notSynced)

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

  func testReadWriteDeleteRepositories() {
    let expectation1 = XCTestExpectation(description: "Should result in success when reading from MockReadWriteDeleteRepository")
    let expectation2 = XCTestExpectation(description: "Should result in success when writing to MockReadWriteDeleteRepository")
    let expectation3 = XCTestExpectation(description: "Should result in success when reading from MockReadWriteDeleteRepository after writing")
    let expectation4 = XCTestExpectation(description: "Should result in success when deleting from MockReadWriteDeleteRepository")
    let expectation5 = XCTestExpectation(description: "Should result in success when reading from MockReadWriteDeleteRepository after deleting")

    let repo = MockReadWriteDeleteRepository()

    XCTAssertEqual(repo.getState(), .notSynced)

    Task {
      let result = try await repo.get()
      XCTAssertEqual(result, "new")
      expectation1.fulfill()
    }

    Task {
      let result = try await repo.set("new")
      XCTAssertEqual(result, "new")
      expectation2.fulfill()
    }

    Task {
      await delay(2.0)

      let result = try await repo.get()
      XCTAssertEqual(result, "new")
      expectation3.fulfill()
    }

    Task {
      await delay(3.0)

      try await repo.delete()
      expectation4.fulfill()
    }

    Task {
      await delay(4.0)

      let result = try await repo.get()
      XCTAssertEqual(result, nil)
      expectation5.fulfill()
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

    Task {
      let result = try await readOnlyRepository.get()
      XCTAssertEqual(result, "old")
      expectation1.fulfill()
    }

    Task {
      let result = try await readWriteRepository.set("new")
      XCTAssertEqual(result, "new")
      expectation2.fulfill()
    }

    Task {
      let result = try await readWriteDeleteRepository.set("new")
      XCTAssertEqual(result, "new")
      expectation3.fulfill()
    }

    wait(for: [expectation1, expectation2, expectation3], timeout: 5.0)
  }
}
