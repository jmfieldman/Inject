//
//  Builder.swift
//  Copyright © 2025 Jason Fieldman.
//

import Foundation

/// Builder is a similar concept to Inject.
///
/// Inject works on singletons with empty initializers, whereas Builder
/// lets you instantiate opaque objects from models.
///
/// Here is an example of how Builder works:
///
/// Listing 1: An API module
/// (This can be imported by anyone.)
///
///   protocol CoolViewController: UIViewController, Buildable {
///     // public API of a CoolViewController
///     var buttonState: Bool { get }
///   }
///
///   struct CoolViewControllerBuilder: Builder {
///     typealias BuildResult = CoolViewController
///
///     // parameters needed to instantiate a CoolViewController
///     let someParam: Int
///   }
///
/// Listing 2: The implementation module
/// (This is only imported by the top-level resolution module.)
///
///   class CoolViewControllerImpl: UIViewController, CoolClass {
///     required init(builder: CoolViewControllerBuilder) {
///       ...
///     }
///   }
///
/// Listing 3: Using from another module
/// (Use the 'build' function to create an opaque instance of
/// the corresponding protocol.)
///
///   let myObj: CoolViewController = CoolViewControllerBuilder(someParam: 3).build()

// MARK: - Builder

/// Applied to any data model that we want to be opaquely built
/// into an associated result object.
public protocol Builder {
    /// This is the associated result type that will be output from
    /// the build operation.
    associatedtype BuildResult
}

/// A public extension on Builder to return the instantiated
/// instance of `BuildResult` for this model.
public extension Builder {
    func build() -> Self.BuildResult {
        BuilderManager.__buildHelper(self)
    }
}

// MARK: - Buildable

/// Apply to a protocol that you want to enforce buildability from
/// a `Builder`.  This enforces that the implementation has an initializer
/// capable of taking in the builder model.
public protocol Buildable {
    associatedtype InputBuilder: Builder
    init(builder: InputBuilder)
}

// MARK: - BuilderManager

public enum BuilderManager {
    private static var buildLookup: [ObjectIdentifier: (Any) -> Any] = [:]
    private static let buildLock = NSLock()

    /// Register a resolution function for the specified type.
    public static func register<B: Builder>(_ type: B.Type, _ resolutionFunction: @escaping (Any) -> B.BuildResult) {
        buildLock.withLock {
            buildLookup[ObjectIdentifier(type)] = resolutionFunction
        }
    }
    
    /// Register a resolution function for the specified type, without using internal locks.
    /// Acceptable for batch registration as part of the app launch process.
    public static func unsafeRegister<B: Builder>(_ type: B.Type, _ resolutionFunction: @escaping (Any) -> B.BuildResult) {
        buildLookup[ObjectIdentifier(type)] = resolutionFunction
    }

    /// A private helper function that extracts the resolutionFunction
    /// from the lookup and creates the instance.
    fileprivate static func __buildHelper<B: Builder>(_ builder: B) -> B.BuildResult {
        guard let resolutionFunction = buildLock.withLock({
            self.buildLookup[ObjectIdentifier(B.self)]
        }) else {
            fatalError("Attempted to build unregistered model: \(B.self)")
        }
        return resolutionFunction(builder) as! B.BuildResult
    }
}
