//
//  Inject.swift
//  Copyright © 2024 Jason Fieldman.
//

import Foundation

public enum Inject {
  /// This map contains the specified singleton generator functions
  /// for Injectable objects.
  private(set) static var injectableResolutionMap: [ObjectIdentifier: () -> Any] = [:]

  /// Contains the current container of resolved Injectables.
  private(set) static var currentInjectableContainer: [ObjectIdentifier: Any] = [:]

  /// A recursive lock protects Injectable resolution and allows
  /// arbitrarily deep re-entrant resolution
  static let injectableLock = NSRecursiveLock()

  /// Contains the current stack of actively resolving Injectables (to
  /// detect infinite-cycles during resolution)
  private(set) static var resolutionStack: [ObjectIdentifier] = []
  private(set) static var resolutionStackSet: Set<ObjectIdentifier> = []

  /// Set this to true to detect resolution cycles during the `resolve`
  /// function. Useful in debug builds.
  public static var detectResolutionCycles: Bool = false

  /// Register a map of ObjectIdentifier -> Construction block for this
  /// instance of the application. Should be done at launch before any
  /// instances are resolved.
  public static func register(
    _ map: [ObjectIdentifier: () -> Any]
  ) {
    injectableResolutionMap.merge(map, uniquingKeysWith: { $1 })
  }

  /// Resolve the specified type into its singleton instance contained
  /// in the current injectable container. Optionally performs resolution
  /// cycle detection if `detectResolutionCycles` is true.
  public static func resolve<T>(_ type: T.Type) -> T {
    let key = ObjectIdentifier(type)

    return injectableLock.withLock {
      if detectResolutionCycles {
        if resolutionStackSet.contains(key) {
          fatalError("Resolution cycle detected: \(resolutionStack) -> \(T.self)")
        }

        resolutionStack.append(key)
        resolutionStackSet.insert(key)
      }

      if let cached = currentInjectableContainer[key], case let result = (cached as! T) {
        return result
      }

      guard let resolutionBlock = injectableResolutionMap[key] else {
        fatalError("No resolution block registered for type: \(type)")
      }

      let newObject = resolutionBlock() as! T
      currentInjectableContainer[key] = newObject

      if detectResolutionCycles {
        resolutionStack.removeLast()
        resolutionStackSet.remove(key)
      }

      return newObject
    }
  }

  /// Resets the current active container by setting it to the new initial map
  public static func resetCurrentContainer(
    initialMap: [ObjectIdentifier: Any]
  ) {
    injectableLock.withLock {
      currentInjectableContainer = initialMap
    }
  }
}
