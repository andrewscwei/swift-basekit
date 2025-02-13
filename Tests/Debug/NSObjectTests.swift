import XCTest
@testable import BaseKit

class NSObjectTests: XCTestCase {
  func testClassName() {
    class MockClass1: NSObject {}
    class MockClass2: NSObject {}

    XCTAssertEqual(MockClass1.className, "MockClass1")
    XCTAssertEqual(MockClass2.className, "MockClass2")
  }
}
