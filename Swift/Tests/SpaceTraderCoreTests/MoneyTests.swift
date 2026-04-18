// Derived from Space Trader by Pieter Spronck, GPLv2.

import XCTest
@testable import SpaceTraderCore

final class MoneyTests: XCTestCase {

    // MARK: currentWorth

    func testCurrentWorthBaseCase() {
        let w = MoneySystem.currentWorth(shipPrice: 10_000, credits: 500, debt: 0, moonBought: false)
        XCTAssertEqual(w, 10_500)
    }

    func testCurrentWorthSubtractsDebt() {
        let w = MoneySystem.currentWorth(shipPrice: 10_000, credits: 500, debt: 2_000, moonBought: false)
        XCTAssertEqual(w, 8_500)
    }

    func testCurrentWorthAddsMoonCost() {
        let w = MoneySystem.currentWorth(shipPrice: 10_000, credits: 500, debt: 0, moonBought: true)
        XCTAssertEqual(w, 10_500 + Money.costMoon)
    }

    // MARK: payInterest

    func testPayInterestNoDebtIsNoop() {
        var c = 500, d = 0
        MoneySystem.payInterest(credits: &c, debt: &d)
        XCTAssertEqual(c, 500)
        XCTAssertEqual(d, 0)
    }

    func testPayInterestSmallDebtChargesMinimumOne() {
        var c = 10, d = 5        // 5/10 = 0, clamped to 1
        MoneySystem.payInterest(credits: &c, debt: &d)
        XCTAssertEqual(c, 9)
        XCTAssertEqual(d, 5)
    }

    func testPayInterestTakesTenPercentWhenAffordable() {
        // C uses a strict `>` comparison, so credits must exceed interest
        // by at least 1 to be debited normally. Here: 1_001 > 1_000.
        var c = 1_001, d = 10_000
        MoneySystem.payInterest(credits: &c, debt: &d)
        XCTAssertEqual(c, 1)
        XCTAssertEqual(d, 10_000)
    }

    func testPayInterestExactlyEqualTakesElseBranch() {
        // Credits == IncDebt exercises the `else` branch in Money.c:62:
        // interest rolls into debt (IncDebt − Credits == 0) and credits
        // clear. This preserves exact parity with the C behavior.
        var c = 1_000, d = 10_000
        MoneySystem.payInterest(credits: &c, debt: &d)
        XCTAssertEqual(c, 0)
        XCTAssertEqual(d, 10_000)
    }

    func testPayInterestBrokeCommanderRollsIntoDebt() {
        var c = 0, d = 10_000
        MoneySystem.payInterest(credits: &c, debt: &d)
        XCTAssertEqual(c, 0)
        XCTAssertEqual(d, 11_000)     // full 1_000 interest added to debt
    }

    func testPayInterestPartiallyDrainsWhenCreditsBelowInterest() {
        var c = 400, d = 10_000
        MoneySystem.payInterest(credits: &c, debt: &d)
        XCTAssertEqual(c, 0)
        XCTAssertEqual(d, 10_000 + 600)
    }

    // MARK: GameState forwards

    func testGameStateCurrentWorthUsesSaveFields() {
        let gs = GameState()
        gs.credits = 2_000
        gs.debt = 500
        gs.moonBought = true
        XCTAssertEqual(gs.currentWorth(shipPrice: 50_000), 50_000 + 2_000 - 500 + Money.costMoon)
    }

    func testGameStatePayInterestMutatesSave() {
        let gs = GameState()
        gs.credits = 1_000
        gs.debt = 5_000
        gs.payInterest()
        XCTAssertEqual(gs.credits, 500)  // 5_000/10 = 500, credits cover it
        XCTAssertEqual(gs.debt, 5_000)
    }
}
