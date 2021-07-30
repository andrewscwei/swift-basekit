import XCTest
@testable import BaseKit

class WeakReferenceTests: XCTestCase {

  func testWeakReference() {
    var foo: NSObject? = NSObject()
    let weakFoo = WeakReference(foo!)

    XCTAssertNotNil(weakFoo.get())
    XCTAssertTrue(foo === weakFoo.get())

    foo = nil

    XCTAssertNil(weakFoo.get())
  }
}
