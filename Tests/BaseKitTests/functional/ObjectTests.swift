import XCTest
@testable import BaseKit

class ObjectTests: XCTestCase {

  func testClassName() {
    class Foo: NSObject {}
    class Bar: NSObject {}

    XCTAssertEqual(Foo.className, "Foo")
    XCTAssertEqual(Bar.className, "Bar")
  }

  func testErrorConvertible() {
    struct Foo: ErrorConvertible {
      func asError() throws -> Error {
        return NSError()
      }
    }

    XCTAssertNoThrow(try Foo().asError())
  }

  func testAnyOptional() {
    var foo: String? = nil

    XCTAssertTrue(foo.isNil)

    foo = "foo"

    XCTAssertFalse(foo.isNil)
  }
}
