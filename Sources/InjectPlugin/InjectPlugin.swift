//
//  Inject.swift
//  Copyright © 2025 Jason Fieldman.
//

import SwiftSyntax
import SwiftCompilerPlugin
import SwiftSyntaxMacros
import Foundation

@main
struct InjectPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        InjectMacro.self,
    ]
}

public struct InjectMacro: DeclarationMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let args = node.arguments
        
        guard args.count == 1 else {
            throw MacroError.invalidUsage("#Inject macro expects one argument")
        }
        
        let typeDecl = args.first!.expression.description.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard typeDecl.hasSuffix(".self"), case let typeName = typeDecl.replacingOccurrences(of: ".self", with: ""), typeName.count > 0 else {
            throw MacroError.invalidUsage("#Inject macro type parameter must be in form TypeName.self")
        }
        
        let varName = typeName.lowercased()

        // Compose: let myVarName: MyProtocol = Inject()
        let declStr = "let \(varName): \(typeName) = Inject()"
        return [DeclSyntax(stringLiteral: declStr)]
    }
}

private enum MacroError: Error, CustomStringConvertible {
    case invalidUsage(String)
    
    var description: String {
        switch self {
        case .invalidUsage(let message):
            return "Invalid usage: \(message)"
        }
    }
}
