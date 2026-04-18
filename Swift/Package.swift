// swift-tools-version:5.9
//
// Space Trader — SwiftUI port
// Derived from Space Trader 1.2.2 by Pieter Spronck (GPLv2).
//
// `SpaceTraderCore` is Foundation-only so it builds on Linux for CI
// (`swift test`) and on macOS/iOS for the app. The `iOSApp` executable
// target is platform-guarded — on Linux it resolves to an empty source
// list and compiles to nothing, so the whole package still builds green.

import PackageDescription

let package = Package(
    name: "SpaceTrader",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],
    products: [
        .library(name: "SpaceTraderCore", targets: ["SpaceTraderCore"]),
    ],
    targets: [
        .target(
            name: "SpaceTraderCore",
            path: "Sources/SpaceTraderCore"
        ),
        .testTarget(
            name: "SpaceTraderCoreTests",
            dependencies: ["SpaceTraderCore"],
            path: "Tests/SpaceTraderCoreTests",
            exclude: [
                "Fixtures/rand_harness.c",
                "Fixtures/rand_harness",
            ],
            resources: [
                .copy("Fixtures/rand_seed_default.txt"),
            ]
        ),
    ]
)
