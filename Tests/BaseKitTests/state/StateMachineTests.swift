import XCTest
@testable import BaseKit

class StateMachineTests: XCTestCase {

  func testStateTypes() {
    let foo = StateType.factory()
    let bar = StateType.factory()
    let baz = StateType.factory()

    XCTAssertEqual(foo.rawValue, 1 << 0)
    XCTAssertEqual(bar.rawValue, 1 << 1)
    XCTAssertEqual(baz.rawValue, 1 << 2)
    XCTAssertFalse(StateType.none.contains(foo))
    XCTAssertTrue(StateType.all.contains(foo))
  }

  func testStateValidator() {
    class Foo {
      let foo: String = "foo"
      let bar: String = "bar"
      let baz: String = "baz"
    }

    let foo = StateType.factory()
    let bar = StateType.factory()
    let baz = StateType.factory()

    let validator = StateValidator.init(keyPaths: [\Foo.foo, \Foo.bar], stateTypes: [foo, bar])

    XCTAssertTrue(validator.isDirty(foo))
    XCTAssertTrue(validator.isDirty(bar))
    XCTAssertTrue(validator.isDirty(foo, bar))
    XCTAssertTrue(validator.isDirty(foo, bar, baz))
    XCTAssertFalse(validator.isDirty(baz))
    XCTAssertTrue(validator.isDirty(\Foo.foo))
    XCTAssertTrue(validator.isDirty(\Foo.bar))
    XCTAssertTrue(validator.isDirty(\Foo.foo, \Foo.bar))
    XCTAssertTrue(validator.isDirty(\Foo.foo, \Foo.bar, \Foo.baz))
    XCTAssertFalse(validator.isDirty(\Foo.baz))
  }

  func testStateMachineDelegate() {
    class Foo: StateMachineDelegate {
      lazy var stateMachine = StateMachine(self)

      func update(check: StateValidator) {}
    }

    XCTAssertNoThrow(Foo())
    XCTAssertNotNil(Foo().stateMachine)
  }

  func testStatefulProperties() {
    let expectation1 = XCTestExpectation(description: "State machine should invalidate `foo` 2 times.")
    expectation1.expectedFulfillmentCount = 2

    let expectation2 = XCTestExpectation(description: "State machine should invalidate `bar` 3 times.")
    expectation2.expectedFulfillmentCount = 3

    class Foo: StateMachineDelegate {
      lazy var stateMachine = StateMachine(self)

      private var expectation1: XCTestExpectation
      private var expectation2: XCTestExpectation

      @Stateful var foo: String = "foo"
      @Stateful var bar: String?

      init(expectation1: XCTestExpectation, expectation2: XCTestExpectation) {
        self.expectation1 = expectation1
        self.expectation2 = expectation2

        stateMachine.start()
      }

      deinit {
        stateMachine.stop()
      }

      func update(check: StateValidator) {
        if check.isDirty(\Foo.foo) {
          expectation1.fulfill()
        }

        if check.isDirty(\Foo.bar) {
          expectation2.fulfill()
        }
      }
    }

    let foo = Foo(expectation1: expectation1, expectation2: expectation2)

    foo.foo = "foo2"
    foo.bar = "bar2"
    foo.bar = "bar3"

    wait(for: [expectation1, expectation2], timeout: 3.0)
  }
}
