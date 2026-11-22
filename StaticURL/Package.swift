// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "StaticURL",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        // Library that exposes the macro as part of its API.
        .library(
            name: "StaticURL",
            targets: ["StaticURL"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "602.0.0")
    ],
    targets: [
        // Macro implementation that performs the source transformation of a macro.
        .macro(
            name: "StaticURLMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),

        // Library that exposes a macro as part of its API, which is used in client programs.
        .target(name: "StaticURL", dependencies: ["StaticURLMacros"]),

        // A test target used to develop the macro implementation.
        .testTarget(
            name: "StaticURLTests",
            dependencies: [
                "StaticURLMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
            ]
        )
    ]
)
