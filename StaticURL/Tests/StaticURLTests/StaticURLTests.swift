import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling.
#if canImport(StaticURLMacros)
import StaticURLMacros

private let testMacros: [String: Macro.Type] = [
    "staticURL": StaticURLMacro.self
]
#endif

final class StaticURLTests: XCTestCase {
    func testExpandsValidURL() throws {
        #if canImport(StaticURLMacros)
        assertMacroExpansion(
            """
            #staticURL("https://example.com/path")
            """,
            expandedSource: """
            Foundation.URL(string: "https://example.com/path")!
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
