// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SFSymbols",
    platforms: [.macOS(.v11), .iOS(.v13), .macCatalyst(.v13), .watchOS(.v6), .tvOS(.v13), .visionOS(.v1)],
    products: [
        .library(
            name: "SFSymbols",
            targets: ["SFSymbols"]
        ),
    ],
    traits: [
        .trait(name: "SwiftUI", description: "Enable SwiftUI support including View conformance and Image extensions"),
    ],
    targets: [
        .target(
            name: "SFSymbols",
            swiftSettings: [
                .define("SFSYMBOLS_SWIFTUI", .when(traits: ["SwiftUI"])),
            ]
        ),
        .testTarget(
            name: "SFSymbolsTests",
            dependencies: ["SFSymbols"]
        ),
    ],
)
