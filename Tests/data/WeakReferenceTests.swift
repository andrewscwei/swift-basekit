import XCTest
@testable import BaseKit

class WeakReferenceTests: XCTestCase {
  func testWeakReference() {
    var object: NSObject? = NSObject()
    let weakObject = WeakReference(object!)

    XCTAssertNotNil(weakObject.get())
    XCTAssertTrue(object === weakObject.get())

    object = nil

    XCTAssertNil(weakObject.get())
  }
}
