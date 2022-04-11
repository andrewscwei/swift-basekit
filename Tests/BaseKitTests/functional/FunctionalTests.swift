import XCTest
@testable import BaseKit

class FunctionalTests: XCTestCase {

  func testAnyOptional() {
    var someOptional: String? = nil

    XCTAssertTrue(someOptional.isNil)

    someOptional = "foo"

    XCTAssertFalse(someOptional.isNil)
  }

  func testClassName() {
    class Foo: NSObject {}
    class Bar: NSObject {}

    XCTAssertEqual(Foo.className, "Foo")
    XCTAssertEqual(Bar.className, "Bar")
  }
}
