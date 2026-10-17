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
        .trait(name: "PrivateSymbols", description: "Enable the private system symbols that ship with the OS, loaded through private AppKit and UIKit API"),
    ],
    targets: [
        .target(
            name: "SFSymbols",
            dependencies: [
                .target(name: "SFSymbolsPrivate", condition: .when(traits: ["PrivateSymbols"])),
            ],
            swiftSettings: [
                .define("SFSYMBOLS_SWIFTUI", .when(traits: ["SwiftUI"])),
                .define("SFSYMBOLS_PRIVATE", .when(traits: ["PrivateSymbols"])),
            ]
        ),
        .target(
            name: "SFSymbolsPrivate"
        ),
        .testTarget(
            name: "SFSymbolsTests",
            dependencies: ["SFSymbols"],
            swiftSettings: [
                .define("SFSYMBOLS_SWIFTUI", .when(traits: ["SwiftUI"])),
                .define("SFSYMBOLS_PRIVATE", .when(traits: ["PrivateSymbols"])),
            ]
        ),
    ],
)
