import XCTest
@testable import BaseKit

class OptionalTests: XCTestCase {
  func testAnyOptional() {
    var someOptional: String? = nil

    XCTAssertTrue(someOptional.isNil)

    someOptional = "foo"

    XCTAssertFalse(someOptional.isNil)
  }
}
