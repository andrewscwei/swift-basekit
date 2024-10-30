import XCTest
@testable import BaseKit

class NSObjectTests: XCTestCase {
  func testClassName() {
    class Foo: NSObject {}
    class Bar: NSObject {}

    XCTAssertEqual(Foo.className, "Foo")
    XCTAssertEqual(Bar.className, "Bar")
  }
}
