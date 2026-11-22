
import Foundation

@freestanding(expression)
public macro staticURL(_ value: StaticString) -> URL = #externalMacro(
    module: "StaticURLMacros",
    type: "StaticURLMacro"
)
