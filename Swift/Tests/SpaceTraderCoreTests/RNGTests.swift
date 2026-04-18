// Derived from Space Trader by Pieter Spronck, GPLv2.

import XCTest
@testable import SpaceTraderCore

final class RNGTests: XCTestCase {

    // MARK: Golden-vector parity with Src/Math.c

    func testRandSeedDefaultMatchesGoldenVector() throws {
        let cases = try loadGoldenVector()
        XCTAssertFalse(cases.isEmpty, "fixture had no cases")

        for testCase in cases {
            let rng = RNG()
            rng.seed(testCase.seed1, testCase.seed2)
            for (i, expected) in testCase.values.enumerated() {
                let got = rng.rand()
                XCTAssertEqual(
                    got, expected,
                    "seed=(\(testCase.seed1),\(testCase.seed2)) step \(i): expected \(expected), got \(got)"
                )
            }
        }
    }

    // MARK: Determinism & reseed behavior

    func testSameSeedProducesSameSequence() {
        let a = RNG()
        a.seed(1, 1)
        let b = RNG()
        b.seed(1, 1)
        for _ in 0..<64 {
            XCTAssertEqual(a.rand(), b.rand())
        }
    }

    func testZeroSeedFallsBackToDefaults() {
        let explicit = RNG()
        explicit.seed(RNG.defaultSeedX, RNG.defaultSeedY)
        let zeroed = RNG()
        zeroed.seed(0, 0)
        for _ in 0..<32 {
            XCTAssertEqual(explicit.rand(), zeroed.rand())
        }
    }

    func testGetRandomIsBounded() {
        let rng = RNG()
        rng.seed(42, 99)
        for _ in 0..<256 {
            let v = rng.getRandom(7)
            XCTAssertTrue((0..<7).contains(v))
        }
    }

    // MARK: Fixture parser

    private struct GoldenCase {
        let seed1: UInt16
        let seed2: UInt16
        let values: [UInt16]
    }

    private func loadGoldenVector() throws -> [GoldenCase] {
        // SwiftPM copies the fixture into the test bundle as a resource.
        guard let url = Bundle.module.url(forResource: "rand_seed_default", withExtension: "txt") else {
            XCTFail("rand_seed_default.txt missing from test bundle resources")
            return []
        }
        let raw = try String(contentsOf: url, encoding: .utf8)

        var cases: [GoldenCase] = []
        var currentSeed: (UInt16, UInt16)? = nil
        var currentValues: [UInt16] = []

        func flush() {
            if let (s1, s2) = currentSeed, !currentValues.isEmpty {
                cases.append(GoldenCase(seed1: s1, seed2: s2, values: currentValues))
            }
            currentSeed = nil
            currentValues = []
        }

        for line in raw.split(whereSeparator: \.isNewline) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty { continue }

            if trimmed.hasPrefix("#") {
                // Header lines of the form "# seed1=<n> seed2=<m>" declare a new case.
                if let s1Range = trimmed.range(of: "seed1="),
                   let s2Range = trimmed.range(of: "seed2=") {
                    flush()
                    let s1Part = trimmed[s1Range.upperBound...]
                        .prefix(while: { $0 != " " })
                    let s2Part = trimmed[s2Range.upperBound...]
                        .prefix(while: { $0 != " " })
                    if let s1 = UInt16(s1Part), let s2 = UInt16(s2Part) {
                        currentSeed = (s1, s2)
                    }
                }
                continue
            }

            if let v = UInt16(trimmed) {
                currentValues.append(v)
            }
        }
        flush()
        return cases
    }
}
