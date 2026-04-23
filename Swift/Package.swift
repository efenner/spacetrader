// swift-tools-version:5.9
//
// Space Trader — SwiftUI port
// Derived from Space Trader 1.2.2 by Pieter Spronck (GPLv2).
//
// Two library targets:
//   - SpaceTraderCore — Foundation-only, builds on Linux for CI.
//   - SpaceTraderUI   — SwiftUI views; Apple platforms only.
//
// The UI layer is declared inside a `#if os(macOS)` guard so Linux
// `swift build` + `swift test` don't try to bring in SwiftUI. On a
// Mac both libraries are visible to Xcode, which can link them into
// a thin Xcode iOS App project that supplies the `@main` wrapper +
// Info.plist / bundle identifier. SwiftPM's own executableTarget
// type doesn't produce a proper iOS `.app` bundle, so we stop short
// of shipping one.

import PackageDescription

#if os(macOS)
let uiTargets: [Target] = [
    .target(
        name: "SpaceTraderUI",
        dependencies: ["SpaceTraderCore"],
        path: "Sources/SpaceTraderUI"
    ),
]
let uiProducts: [Product] = [
    .library(name: "SpaceTraderUI", targets: ["SpaceTraderUI"]),
]
#else
let uiTargets: [Target] = []
let uiProducts: [Product] = []
#endif

let package = Package(
    name: "SpaceTrader",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],
    products: [
        .library(name: "SpaceTraderCore", targets: ["SpaceTraderCore"]),
    ] + uiProducts,
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
                // Compiled by gcc on-demand to regenerate the RNG
                // golden vector; .gitignored so it's only present on
                // a Linux dev host that has built it. Mac users will
                // see a harmless "File not found" warning here.
                "Fixtures/rand_harness",
            ],
            resources: [
                .copy("Fixtures/rand_seed_default.txt"),
            ]
        ),
    ] + uiTargets
)
