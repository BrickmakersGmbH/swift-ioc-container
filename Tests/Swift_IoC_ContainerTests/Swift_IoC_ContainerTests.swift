import XCTest
@testable import Swift_IoC_Container

protocol PIoCTestProtocol {}
protocol PIoCTestProtocol2 {}
protocol PIoCTestProtocol3 {}
protocol PIoCTestA {}
protocol PIoCTestB {}

final class swift_ioc_containerTests: XCTestCase {
    class IoCTestClass: PIoCTestProtocol {}
    class IoCTestClass2: PIoCTestProtocol2 {}
    class IoCTestClass3: PIoCTestProtocol3 {}
    class LazyIoCTestClass: PIoCTestProtocol { static var intialized:Bool = false }
    class CounterIoCTestClass: PIoCTestProtocol {
        static var next:Int = 0
        let nr: Int
        init() {
            self.nr = CounterIoCTestClass.next
            CounterIoCTestClass.next += 1
        }
    }

    class A: PIoCTestA {
        required init() {
            print("instantiated A")
        }
    }

    class B: PIoCTestB {
        init(_ a: PIoCTestA = IoC.shared.resolveOrNil()!) {
            print("instantiated B")
        }
    }

    override func setUp() {
        super.setUp()
        IoC.shared.unregisterAll()
    }

    func test_resolve_Should_Throw_Error_If_Nothing_Is_Registered() {
        assertResolveError(PIoCTestProtocol.self)
    }

    func test_resolveOrNil_Should_Return_Nil_If_Nothing_Is_Registered() {
        XCTAssertNil(
            IoC.shared.resolveOrNil(PIoCTestProtocol.self)
        )
    }

    func test_resolve_Should_ResolveOrNil_Registered_Singleton() {
        let testObject = IoCTestClass()

        IoC.shared.registerSingleton(PIoCTestProtocol.self, testObject)
        let result = IoC.shared.resolveOrNil(PIoCTestProtocol.self)

        XCTAssertNotNil(result)
        XCTAssertTrue(result as AnyObject === testObject)
    }

    func test_resolve_Should_Resolve_Registered_Singleton() throws {
        let testObject = IoCTestClass()

        IoC.shared.registerSingleton(PIoCTestProtocol.self, testObject)
        let result = try IoC.shared.resolve(PIoCTestProtocol.self)

        XCTAssertNotNil(result)
        XCTAssertTrue(result as AnyObject === testObject)
    }

    func test_resolve_Should_Resolve_Registered_Singleton_implicitly() throws {
        let testObject = IoCTestClass()

        IoC.shared.registerSingleton(PIoCTestProtocol.self, testObject)
        let result:PIoCTestProtocol = try IoC.shared.resolve()

        XCTAssertNotNil(result)
        XCTAssertTrue(result as AnyObject === testObject)
    }

    func test_resolve_Should_ResolveOrNil_Registered_Singleton_implicitly() {
        let testObject = IoCTestClass()

        IoC.shared.registerSingleton(PIoCTestProtocol.self, testObject)
        let result:PIoCTestProtocol? = IoC.shared.resolveOrNil()

        XCTAssertNotNil(result)
        XCTAssertTrue(result as AnyObject === testObject)
    }

    func test_registerSingleton_always_returns_the_same_instance() {
        let testSingleton = IoCTestClass()

        IoC.shared.registerSingleton(PIoCTestProtocol.self, testSingleton)

        assertSingletonIsRegistered(testSingleton, type: PIoCTestProtocol.self)
    }

    func test_registerLazySingleton_always_returns_the_same_instance() {
        let testSingleton = IoCTestClass()

        IoC.shared.registerLazySingleton(PIoCTestProtocol.self, testSingleton)

        assertSingletonIsRegistered(testSingleton, type: PIoCTestProtocol.self)
    }

    func test_registerSingleton_removes_old_lazy_registration() throws {
        let testSingletonOld = IoCTestClass()
        let testSingletonNew = IoCTestClass()

        IoC.shared.registerLazySingleton(PIoCTestProtocol.self, testSingletonOld)
        IoC.shared.registerSingleton(PIoCTestProtocol.self, testSingletonNew)

        assertSingletonIsRegistered(testSingletonNew, type: PIoCTestProtocol.self)
    }

    func test_registerType_causes_resolve_to_always_create_a_new_instance() throws {
        IoC.shared.registerType(PIoCTestProtocol.self, { () -> PIoCTestProtocol in CounterIoCTestClass() })

        let result1 = try IoC.shared.resolve(PIoCTestProtocol.self) as? CounterIoCTestClass
        let result2 = try IoC.shared.resolve(PIoCTestProtocol.self) as? CounterIoCTestClass

        XCTAssertNotEqual(result1?.nr, result2?.nr)
    }

    func test_unregisterAll_removes_registrations() throws {
        IoC.shared.registerType(PIoCTestProtocol.self, IoCTestClass())
        IoC.shared.registerSingleton(PIoCTestProtocol2.self, IoCTestClass2())

        IoC.shared.unregisterAll()

        assertResolveError(PIoCTestProtocol.self)
        assertResolveError(PIoCTestProtocol2.self)
    }

    func test_constructType() throws{
        IoC.shared.registerLazySingleton(PIoCTestA.self, A())
        IoC.shared.registerLazySingleton(PIoCTestB.self, B())

        let result = try IoC.shared.resolve(PIoCTestB.self)

        XCTAssertNotNil(result)
        XCTAssert(result is B)
    }


    func test_inject_property_should_resolve_registered_type() {
        #if swift(>=5.1)  // check for swift 5.1 and later
        
        class TestClassWhichUsesInjected {
            @Injected var result : PIoCTestProtocol
        }
        
        let testObject = IoCTestClass()

        IoC.shared.registerSingleton(PIoCTestProtocol.self, testObject)
        
        let classInstance = TestClassWhichUsesInjected()
        let result = classInstance.result

        XCTAssertNotNil(result)
        XCTAssertTrue(result as AnyObject === testObject)
        
        #else
       
        XCTAssert(true, "Property wrapper is not supported in Swift < 5.1, so this test is always true!")
        
        #endif
    }

    
    func assertResolveError<T>(_ interface: T.Type) {
        assertError({ ()->Void in
                _ = try IoC.shared.resolve(T.self)
            },
            predicate: { e -> Bool in e is IoCError })
    }

    func assertSingletonIsRegistered<T>(_ testSingleton: AnyObject, type: T.Type, file:StaticString = #file, line: UInt = #line) {
        XCTAssertTrue(testSingleton === IoC.shared.resolveOrNil(type) as AnyObject, "different singleton instance than expected", file: file, line: line)
        XCTAssertTrue(testSingleton === IoC.shared.resolveOrNil(type) as AnyObject, "different singleton instance than expected", file: file, line: line)
        XCTAssertTrue(testSingleton === (try! IoC.shared.resolve(type)) as AnyObject, "different singleton instance than expected", file: file, line: line)
        XCTAssertTrue(testSingleton === (try! IoC.shared.resolve(type)) as AnyObject, "different singleton instance than expected", file: file, line: line)
    }


    func assertError(_ action: () throws -> Void, file: StaticString = #file, line: UInt = #line, predicate: (_: Error) -> Bool) {
        do {
            try action()
        }
        catch let error {
            XCTAssert(predicate(error), file: file, line: line)
            return
        }
        XCTAssert(false, "no error was thrown or matched the predicate", file: file, line: line);
    }

    static var allTests = [
        ("test_resolve_Should_Throw_Error_If_Nothing_Is_Registered", test_resolve_Should_Throw_Error_If_Nothing_Is_Registered),
        ("test_resolveOrNil_Should_Return_Nil_If_Nothing_Is_Registered", test_resolveOrNil_Should_Return_Nil_If_Nothing_Is_Registered),
        ("test_resolve_Should_ResolveOrNil_Registered_Singleton", test_resolve_Should_ResolveOrNil_Registered_Singleton),
        ("test_resolve_Should_Resolve_Registered_Singleton", test_resolve_Should_Resolve_Registered_Singleton),
        ("test_resolve_Should_Resolve_Registered_Singleton_implicitly", test_resolve_Should_Resolve_Registered_Singleton_implicitly),
        ("test_resolve_Should_ResolveOrNil_Registered_Singleton_implicitly", test_resolve_Should_ResolveOrNil_Registered_Singleton_implicitly),
        ("test_registerSingleton_always_returns_the_same_instance", test_registerSingleton_always_returns_the_same_instance),
        ("test_registerLazySingleton_always_returns_the_same_instance", test_registerLazySingleton_always_returns_the_same_instance),
        ("test_registerSingleton_removes_old_lazy_registration", test_registerSingleton_removes_old_lazy_registration),
        ("test_registerType_causes_resolve_to_always_create_a_new_instance", test_registerType_causes_resolve_to_always_create_a_new_instance),
        ("test_unregisterAll_removes_registrations", test_unregisterAll_removes_registrations),
        ("test_constructType", test_constructType),
    ]
}

extension XCTestCase {
	func expectFatalError(expectedMessage: String, testcase: @escaping () -> Void) {
		let expectation = self.expectation(description: "expectingFatalError")
		var assertionMessage: String? = nil
		FatalErrorUtil.replaceFatalError { message, _, _ in
			assertionMessage = message
			expectation.fulfill()
			self.unreachable()
		}
		DispatchQueue.global(qos: .userInitiated).async(execute: testcase)
		waitForExpectations(timeout: 2) { _ in
			XCTAssertEqual(assertionMessage, expectedMessage)
			FatalErrorUtil.restoreFatalError()
		}
	}
	private func unreachable() -> Never {
		repeat {
			RunLoop.current.run()
		} while (true)
	}
}
