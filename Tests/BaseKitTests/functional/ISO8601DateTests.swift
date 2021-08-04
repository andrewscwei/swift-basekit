import XCTest
@testable import BaseKit

class ISO8601DateTests: XCTestCase {

  func testISO8601Formatter() {
    let formatter = Formatter.iso8601
    XCTAssertNotNil(formatter.date(from: "2020-07-17T02:42:06.054Z"))
    XCTAssertNil(formatter.date(from: "2020-07-17T02:42:06"))
    XCTAssertNil(formatter.date(from: "foo"))
  }

  func testTransformISO8601StringToDate() {
    XCTAssertNil("foo".toFormattedDate())
    XCTAssertNil("2020-07-17T02:42:06".toFormattedDate())
    XCTAssertNotNil("2020-07-17T02:42:06.054Z".toFormattedDate())
  }
}
