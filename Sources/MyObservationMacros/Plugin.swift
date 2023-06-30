import Foundation
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main struct Plugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        MyObservableMacro.self,
        MyObservedPropertyMacro.self
    ]
}
