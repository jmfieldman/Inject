//
//  InjectMacros.swift
//  Copyright © 2024 Jason Fieldman.
//

import Foundation
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct InjectMacros: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    HydratableMacro.self,
  ]
}
