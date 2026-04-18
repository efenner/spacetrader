// Derived from Space Trader by Pieter Spronck, GPLv2.
//
// Port of Src/Math.c's Rand / RandSeed / GetRandom2.
//
// The original code declares SeedX/SeedY as 16-bit UInt16. Two consequences
// worth spelling out, because Swift is stricter about widths than C:
//
//   1. `SeedX & MAX_WORD` is a no-op on a UInt16, and `SeedX >> 16` is always
//      zero, so each step reduces to `SeedX = UInt16(a &* SeedX)` with natural
//      16-bit wraparound.
//   2. The return expression `(SeedX << 16) + (SeedY & MAX_WORD)` is evaluated
//      at UInt16 width — the left shift therefore drops to zero and Rand()
//      effectively returns `SeedY` cast to UInt16. Callers in the original
//      source (`GetRandom2`, `GetRandom`) consume the value modulo some
//      `maxVal`, so only the low 16 bits matter either way.
//
// We verify bit-identical output against a gcc-compiled copy of the original
// `Rand` / `RandSeed` via Tests/SpaceTraderCoreTests/Fixtures.

import Foundation

public final class RNG {
    /// Defaults pulled from `Src/Math.c:79-80`. Declared there as 32-bit
    /// integer literals assigned into `UInt16`, so they truncate on init.
    @inlinable public static var defaultSeedX: UInt16 { UInt16(truncatingIfNeeded: 521_288_629) }
    @inlinable public static var defaultSeedY: UInt16 { UInt16(truncatingIfNeeded: 362_436_069) }

    /// Multipliers from `Src/Math.c:92-93`.
    @usableFromInline static let mulA: UInt16 = 18_000
    @usableFromInline static let mulB: UInt16 = 30_903

    @usableFromInline var seedX: UInt16
    @usableFromInline var seedY: UInt16

    public init() {
        self.seedX = Self.defaultSeedX
        self.seedY = Self.defaultSeedY
    }

    /// Port of `RandSeed(UInt16, UInt16)` from `Src/Math.c:101-112`.
    /// A zero seed means "use the default", per the original contract.
    public func seed(_ seed1: UInt16, _ seed2: UInt16) {
        seedX = seed1 != 0 ? seed1 : Self.defaultSeedX
        seedY = seed2 != 0 ? seed2 : Self.defaultSeedY
    }

    /// Port of `Rand()` from `Src/Math.c:90-99`. `&*` is Swift's overflow
    /// multiply, matching the implicit 16-bit wraparound in the C version.
    @discardableResult
    public func rand() -> UInt16 {
        seedX = Self.mulA &* seedX
        seedY = Self.mulB &* seedY
        return seedY
    }

    /// Port of `GetRandom2(int)` from `Src/Math.c:85-88`. Returns a value in
    /// `0..<maxVal`. Callers must ensure `maxVal > 0`, matching the C
    /// precondition (the original divides by zero otherwise).
    public func getRandom(_ maxVal: Int) -> Int {
        precondition(maxVal > 0, "GetRandom maxVal must be positive")
        return Int(rand()) % maxVal
    }
}
