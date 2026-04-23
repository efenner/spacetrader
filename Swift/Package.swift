// swift-tools-version:5.9
//
// Space Trader — SwiftUI port
// Derived from Space Trader 1.2.2 by Pieter Spronck (GPLv2).
//
// `SpaceTraderCore` is Foundation-only so it builds on Linux for CI
// (`swift test`) and on macOS/iOS for the app. The `iOSApp` executable
// target only exists when the package is configured on a macOS host —
// `swift package` evaluates this file on the current host, and Linux
// doesn't have SwiftUI / UIKit / the iOS SDK, so its target list stays
// empty.

import PackageDescription

#if os(macOS)
let iosAppTargets: [Target] = [
    .executableTarget(
        name: "iOSApp",
        dependencies: ["SpaceTraderCore"],
        path: "Sources/iOSApp"
    ),
]
let iosAppProducts: [Product] = [
    .executable(name: "iOSApp", targets: ["iOSApp"]),
]
#else
let iosAppTargets: [Target] = []
let iosAppProducts: [Product] = []
#endif

let package = Package(
    name: "SpaceTrader",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],
    products: [
        .library(name: "SpaceTraderCore", targets: ["SpaceTraderCore"]),
    ] + iosAppProducts,
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
    ] + iosAppTargets
)
