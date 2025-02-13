import XCTest
@testable import BaseKit

class OptionalTests: XCTestCase {
  func testAnyOptional() {
    let mockOptional1: String? = nil
    let mockOptional2: String? = "foo"

    XCTAssertTrue(mockOptional1.isNil)
    XCTAssertFalse(mockOptional2.isNil)
  }
}
