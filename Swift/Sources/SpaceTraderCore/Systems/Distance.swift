// Derived from Space Trader by Pieter Spronck, GPLv2.
//
// Port of the integer-math helpers in Src/Math.c:42-72. The original game
// does not link the C math library (too expensive on a Palm) and uses a
// hand-rolled integer square root. We reproduce the exact rounding so
// travel ranges and distance-gated events behave the same as the C game.

import Foundation

public enum Distance {

    /// `SQR(a)` macro from `Src/spacetrader.h:447`.
    @inlinable public static func sqr(_ a: Int) -> Int { a * a }

    /// Port of `sqrt(int)` from `Src/Math.c:44-55`. Returns the integer
    /// whose square is nearest to `a`, preferring the smaller value on a
    /// tie (matching the C code's `i--` tie-break).
    public static func isqrt(_ a: Int) -> Int {
        if a <= 0 { return 0 }
        var i = 0
        while sqr(i) < a { i += 1 }
        if i > 0 {
            if (sqr(i) - a) > (a - sqr(i - 1)) {
                i -= 1
            }
        }
        return i
    }

    /// Port of `SqrDistance` from `Src/Math.c:60-63`: squared 2-D distance
    /// between two solar-system grid points. Callers need only the rank
    /// for proximity tests, which is why the C code uses this flavor.
    @inlinable public static func sqrDistance(ax: Int, ay: Int, bx: Int, by: Int) -> Int {
        sqr(ax - bx) + sqr(ay - by)
    }

    /// Port of `RealDistance` from `Src/Math.c:69-72`. Returns the
    /// integer-rounded Euclidean distance between two systems.
    @inlinable public static func realDistance(ax: Int, ay: Int, bx: Int, by: Int) -> Int {
        isqrt(sqrDistance(ax: ax, ay: ay, bx: bx, by: by))
    }
}
