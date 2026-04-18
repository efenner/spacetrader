// Derived from Space Trader by Pieter Spronck, GPLv2.

import XCTest
@testable import SpaceTraderCore

final class DistanceTests: XCTestCase {

    func testSqrMatchesIntegerSquare() {
        for i in -50...50 {
            XCTAssertEqual(Distance.sqr(i), i * i)
        }
    }

    func testIsqrtOfPerfectSquaresIsExact() {
        for i in 0...200 {
            XCTAssertEqual(Distance.isqrt(i * i), i)
        }
    }

    func testIsqrtRoundsToNearestWithTieGoingDown() {
        // Between 3^2=9 and 4^2=16: midpoint is 12.5, so 12→3, 13→4.
        // The C code's tiebreak preserves the smaller i when |i^2 − a|
        // exactly equals |a − (i−1)^2|; a strict `>` comparison means a
        // tie resolves to the larger i. We exercise both sides.
        XCTAssertEqual(Distance.isqrt(12), 3) // |16-12|=4 > |12-9|=3  → keep 3
        XCTAssertEqual(Distance.isqrt(13), 4) // |16-13|=3 > |13-9|=4  → no decrement, stay at 4
        XCTAssertEqual(Distance.isqrt(0), 0)
        XCTAssertEqual(Distance.isqrt(1), 1)
        XCTAssertEqual(Distance.isqrt(2), 1) // |4-2|=2 > |2-1|=1 → decrement to 1
    }

    func testIsqrtOfNegativeIsZero() {
        // Defensive: the C code assumes non-negative input (its while loop
        // exits immediately), so zero is the safe and matching answer.
        XCTAssertEqual(Distance.isqrt(-1), 0)
        XCTAssertEqual(Distance.isqrt(-100), 0)
    }

    func testSqrDistanceAndRealDistance() {
        // 3-4-5 triangle.
        XCTAssertEqual(Distance.sqrDistance(ax: 0, ay: 0, bx: 3, by: 4), 25)
        XCTAssertEqual(Distance.realDistance(ax: 0, ay: 0, bx: 3, by: 4), 5)

        // 5-12-13 triangle in either direction.
        XCTAssertEqual(Distance.sqrDistance(ax: 10, ay: 10, bx: 15, by: 22), 169)
        XCTAssertEqual(Distance.realDistance(ax: 10, ay: 10, bx: 15, by: 22), 13)

        // Same-point → zero.
        XCTAssertEqual(Distance.realDistance(ax: 7, ay: 7, bx: 7, by: 7), 0)

        // Non-perfect square: dx=1, dy=1, sqr=2, isqrt=1.
        XCTAssertEqual(Distance.realDistance(ax: 0, ay: 0, bx: 1, by: 1), 1)
    }
}
