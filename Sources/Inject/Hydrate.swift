//
//  Hydrate.swift
//  Copyright © 2024 Jason Fieldman.
//

import Foundation

/// Hydrate is a similar concept to Inject.
///
/// Inject works on singletons with empty initializers, whereas Hydrate
/// lets you instantiate opaque objects from models.
///
/// Here is an example of how Hydrate works:
///
/// Listing 1: An API module
/// (This can be imported by anyone.)
///
///   protocol CoolClass: UIViewController, Hydratable {
///     var buttonState: Bool { get }
///   }
///
///   struct CoolClassInitModel: HydratingModel {
///     typealias HydratedResult = CoolClass
///
///     let someParam: Int
///   }
///
/// Listing 2: The implementation module
/// (This is only imported by the top-level resolution module.)
///
///   class CoolClassImpl: UIViewController, CoolClass {
///     required init(model: CoolClassInitModel) {
///       ...
///     }
///   }
///
/// Listing 3: Using from another module
/// (Use the 'hydrate' function to create an opaque instance of
/// the corresponding protocol.)
///
///   let myObj: CoolClass = CoolClassInitModel(someParam: 3).hydrate()

// MARK: - HydratingModel

/// Applied to any data model that we want to be opaquely hydrated
/// into an associated result object.
public protocol HydratingModel {
  /// This is the associated result type that will be output from
  /// the hydration operation.
  associatedtype HydratedResult
}

/// A public extension on HydratableModel to return the instantiated
/// instance of `HydratedResult` for this model.
public extension HydratingModel {
  func hydrate() -> Self.HydratedResult {
    Hydrate.hydrationHelper(self)
  }
}

// MARK: - Hydratable

/// Applied to an implementation class that can be hydrated from
/// a `HydratableModel`.  This enforces that it has an initializer
/// capable of taking in the model.
public protocol Hydratable {
  associatedtype InputModel: HydratingModel
  init(model: InputModel)
}

// MARK: - Hydrate

public enum Hydrate {
  private static var hydrationLookup: [ObjectIdentifier: (Any) -> any Hydratable] = [:]
  private static let hydrationLock = NSLock()

  public static func register(
    _ map: [ObjectIdentifier: (Any) -> any Hydratable]
  ) {
    hydrationLookup.merge(map, uniquingKeysWith: { $1 })
  }

  /// A private helper function to the hydration that extracts the function
  /// from the lookup and creates the instance.
  fileprivate static func hydrationHelper<M: HydratingModel>(_ model: M) -> M.HydratedResult {
    guard let lookup = hydrationLock.withLock({
      self.hydrationLookup[ObjectIdentifier(M.self)]
    }) else {
      fatalError("Attempted to hydrate unregistered model: \(M.self)")
    }
    return lookup(model) as! M.HydratedResult
  }
}
