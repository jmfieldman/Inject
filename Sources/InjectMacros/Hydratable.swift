//
//  Hydratable.swift
//  Copyright © 2024 Jason Fieldman.
//

import Foundation
import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct HydratableMacro: Macro {
  public static func expansion(
    of node: AttributeSyntax,
    providingProtocolsFrom decl: DeclSyntax
  ) -> DeclSyntax? {
    guard var protocolDecl = decl.as(ProtocolDeclSyntax.self) else {
      return nil // Only expand for protocols
    }

    // Check if the protocol already conforms to `CanBeHydrated`
    let alreadyConforms = protocolDecl.inheritanceClause?.inheritedTypes.contains {
      $0.type.description == "CanBeHydrated"
    } ?? false

    guard !alreadyConforms else {
      return decl // No changes if already conforms
    }

    // Add `CanBeHydrated` conformance
    var newInheritance = protocolDecl.inheritanceClause ?? InheritanceClauseSyntax {}

    let newType = InheritedTypeSyntax(type: IdentifierTypeSyntax(
      name: .identifier("CanByHydrated")
    ))

    newInheritance.inheritedTypes.append(newType)

    // Return the updated protocol declaration
    protocolDecl.inheritanceClause = newInheritance

    return DeclSyntax(protocolDecl)
  }
}
