import XCTest
@testable import BaseKit

class ObservableTests: XCTestCase {
  protocol MockObserver1: AnyObject {
    func foo() -> String
  }

  protocol MockObserver2: AnyObject {
    func bar() -> String
  }

  class SomeMockObserver: MockObserver1, MockObserver2 {
    func foo() -> String { "foo" }
    func bar() -> String { "bar" }
  }

  class SomeMockObservable1: Observable {
    typealias Observer = MockObserver1

    var observers: [WeakReference<any Observer>] = []
  }

  class SomeMockObservable2: Observable {
    typealias Observer = MockObserver2

    var observers: [WeakReference<any Observer>] = []
  }


  func test() {
    let observable1 = SomeMockObservable1()
    let observable2 = SomeMockObservable2()
    let observer = SomeMockObserver()

    observable1.addObserver(observer)
    observable2.addObserver(observer)

    Task {
      observable1.notifyObservers { XCTAssertEqual($0.foo(), "foo") }
    }

    Task {
      observable2.notifyObservers { XCTAssertEqual($0.bar(), "bar") }
    }
  }
}
