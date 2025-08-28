
import Combine
@testable import Inject
import UIKit
import XCTest

class BuilderTests: XCTestCase {
    func testGenericClass() {
        BuilderManager.register(GenericClassBuilder.self) { builder in
            return GenericClassImpl(builder: builder as! GenericClassBuilder)
        }

        let instance: any GenericClass = GenericClassBuilder(someParam: 42).build()
        XCTAssertTrue(instance is GenericClassImpl)
    }
    
    func testViewControllerClass() {
        BuilderManager.register(ViewControllerClassBuilder.self) { builder in
            return ViewControllerClassImpl(builder: builder as! ViewControllerClassBuilder)
        }

        let instance: any ViewControllerClass = ViewControllerClassBuilder(someParam: 42).build()
        XCTAssertTrue(instance is ViewControllerClassImpl)
        
        // Should be able to use normal view controller methods
        let _ = instance.navigationController
        let _ = UINavigationController(rootViewController: instance)
    }
    
    func testFunctionBased() {
        BuilderManager.register(MyPublisherBuilder.self) { builder in
            return MyPublisherBuilderImpl(builder: builder as! MyPublisherBuilder)
        }

        let publisher: AnyPublisher<Int, Never> = MyPublisherBuilder(someParam: 42).build()
        
        var result: Int?
        _ = publisher.sink { result = $0 }
        XCTAssertEqual(result, 42)
    }
}

// MARK: GenericClass
// A generic NSObject test class

// Public API

public protocol GenericClass: Buildable {}

public struct GenericClassBuilder: Builder {
    public typealias BuildResult = GenericClass
    let someParam: Int
}

// Protected Implementation

private class GenericClassImpl: NSObject, GenericClass {
    required init(builder: GenericClassBuilder) {
        super.init()
    }
}

// MARK: ViewControllerClass
// A generic UIViewController-based test class

// Public API

public protocol ViewControllerClass: UIViewController, Buildable {}

public struct ViewControllerClassBuilder: Builder {
    public typealias BuildResult = ViewControllerClass
    let someParam: Int
}

// Protected Implementation

private class ViewControllerClassImpl: UIViewController, ViewControllerClass {
    required init(builder: ViewControllerClassBuilder) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: FunctionBased
// Using a generic protected function to perform arbitrary operations
// and return an arbitrary type during the build process.

// Public API

// This example shows that you do not need to define an explicit result
// type if one already exists.

public struct MyPublisherBuilder: Builder {
    public typealias BuildResult = AnyPublisher<Int, Never>
    let someParam: Int
}

// Protected Implementation

// An example showing that the "implementation" does not need to be a
// class itself; the syntax for instantiation and function calling are the
// same -- both return the corresponding `BuildResult`

func MyPublisherBuilderImpl(builder: MyPublisherBuilder) -> AnyPublisher<Int, Never> {
    return Just(builder.someParam).eraseToAnyPublisher()
}
