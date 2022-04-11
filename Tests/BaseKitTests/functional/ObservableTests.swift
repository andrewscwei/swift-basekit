import XCTest
@testable import BaseKit

protocol MockObserver1: AnyObject {
  func foo() -> String
}

protocol MockObserver2: AnyObject {
  func bar() -> String
}

class ObservableTests: XCTestCase {

  func testObservable() {
    class SomeMockObserver: MockObserver1, MockObserver2 {
      func foo() -> String { "foo" }
      func bar() -> String { "bar" }
    }

    class SomeMockObservable1: Observable {
      typealias Observer = MockObserver1
    }

    class SomeMockObservable2: Observable {
      typealias Observer = MockObserver2
    }

    let observable1 = SomeMockObservable1()
    let observable2 = SomeMockObservable2()
    let observer = SomeMockObserver()

    observable1.addObserver(observer)
    observable2.addObserver(observer)
    observable1.notifyObservers { XCTAssertEqual($0.foo(), "foo") }
    observable2.notifyObservers { XCTAssertEqual($0.bar(), "bar") }
  }
}

