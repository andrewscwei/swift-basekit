import XCTest
@testable import BaseKit

class DependencyInjectionTests: XCTestCase {

  func testSingletonDependencies() {
    let container = DependencyInjectionContainer.default
    XCTAssertNotNil(container)

    class Foo {}

    container.register(Foo.self, component: Foo())

    let foo1 = container.resolve(Foo.self)
    let foo2 = container.resolve(Foo.self)

    XCTAssertTrue(foo1 === foo2)
  }

  func testFactoryDependencies() {
    let container = DependencyInjectionContainer.default
    XCTAssertNotNil(container)

    class Foo {}

    container.register(Foo.self, factory: { Foo() })

    let foo1 = container.resolve(Foo.self)
    let foo2 = container.resolve(Foo.self)

    XCTAssertTrue(foo1 !== foo2)
  }

  func testInjection() {
    let container = DependencyInjectionContainer.default
    XCTAssertNotNil(container)

    class Foo {}

    container.register(Foo.self, factory: { Foo() })

    class Bar {
      @Inject var foo: Foo
    }

    let bar = Bar()

    XCTAssertNotNil(bar.foo)
  }
}
