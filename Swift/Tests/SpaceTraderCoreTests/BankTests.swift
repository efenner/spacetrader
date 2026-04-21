// Derived from Space Trader by Pieter Spronck, GPLv2.

import XCTest
@testable import SpaceTraderCore

final class BankTests: XCTestCase {

    // MARK: maxLoan — record tier

    func testMaxLoanDubiousRecordGets500() {
        // dubious = -5, one below Clean (0), so the capped tier kicks in.
        let cap = BankSystem.maxLoan(
            policeRecordScore: PoliceRecordScore.dubious,
            currentWorth: 1_000_000
        )
        XCTAssertEqual(cap, 500)
    }

    func testMaxLoanCriminalRecordGets500() {
        let cap = BankSystem.maxLoan(
            policeRecordScore: PoliceRecordScore.criminal,
            currentWorth: 1_000_000
        )
        XCTAssertEqual(cap, 500)
    }

    // MARK: maxLoan — clamp band

    func testMaxLoanFloorIs1000() {
        // 2_000 / 10 = 200, /500 = 0, *500 = 0 → clamped up to 1_000.
        let cap = BankSystem.maxLoan(
            policeRecordScore: PoliceRecordScore.clean,
            currentWorth: 2_000
        )
        XCTAssertEqual(cap, 1_000)
    }

    func testMaxLoanCeilingIs25000() {
        // 1M / 10 = 100_000, stepped → 100_000, clamped down to 25_000.
        let cap = BankSystem.maxLoan(
            policeRecordScore: PoliceRecordScore.hero,
            currentWorth: 1_000_000
        )
        XCTAssertEqual(cap, 25_000)
    }

    func testMaxLoanRoundsDownToNearest500() {
        // 123_456 / 10 = 12_345, /500 = 24 (int div), *500 = 12_000.
        let cap = BankSystem.maxLoan(
            policeRecordScore: PoliceRecordScore.clean,
            currentWorth: 123_456
        )
        XCTAssertEqual(cap, 12_000)
    }

    func testMaxLoanAtCleanBoundaryTakesTheUpperTier() {
        // Police score exactly == CLEANSCORE hits the if-branch.
        let cap = BankSystem.maxLoan(
            policeRecordScore: PoliceRecordScore.clean,
            currentWorth: 50_000
        )
        // 50_000 / 10 = 5_000, stepped → 5_000, clamped → 5_000.
        XCTAssertEqual(cap, 5_000)
    }

    // MARK: getLoan

    func testGetLoanCapsAtMaxMinusDebt() {
        var credits = 0, debt = 1_000
        let borrowed = BankSystem.getLoan(
            amount: 10_000,
            maxLoan: 5_000,
            credits: &credits,
            debt: &debt
        )
        // 5_000 − 1_000 = 4_000 headroom, amount exceeds it.
        XCTAssertEqual(borrowed, 4_000)
        XCTAssertEqual(credits, 4_000)
        XCTAssertEqual(debt, 5_000)
    }

    func testGetLoanCapsAtAmountWhenBelowHeadroom() {
        var credits = 100, debt = 0
        let borrowed = BankSystem.getLoan(
            amount: 2_000,
            maxLoan: 25_000,
            credits: &credits,
            debt: &debt
        )
        XCTAssertEqual(borrowed, 2_000)
        XCTAssertEqual(credits, 2_100)
        XCTAssertEqual(debt, 2_000)
    }

    // MARK: payBack

    func testPayBackCapsAtDebt() {
        var credits = 10_000, debt = 500
        let paid = BankSystem.payBack(
            amount: 10_000,
            credits: &credits,
            debt: &debt
        )
        XCTAssertEqual(paid, 500)
        XCTAssertEqual(credits, 9_500)
        XCTAssertEqual(debt, 0)
    }

    func testPayBackCapsAtCredits() {
        var credits = 50, debt = 1_000
        let paid = BankSystem.payBack(
            amount: 99_999, // the C UI's "pay everything" sentinel
            credits: &credits,
            debt: &debt
        )
        XCTAssertEqual(paid, 50)
        XCTAssertEqual(credits, 0)
        XCTAssertEqual(debt, 950)
    }

    func testPayBackNoDebtIsNoop() {
        var credits = 1_000, debt = 0
        let paid = BankSystem.payBack(
            amount: 500,
            credits: &credits,
            debt: &debt
        )
        XCTAssertEqual(paid, 0)
        XCTAssertEqual(credits, 1_000)
        XCTAssertEqual(debt, 0)
    }

    // MARK: GameState forwards

    func testGameStateMaxLoanUsesPoliceRecord() {
        let gs = GameState()
        gs.save.policeRecordScore = PoliceRecordScore.criminal
        XCTAssertEqual(gs.maxLoan(currentWorth: 1_000_000), 500)

        gs.save.policeRecordScore = PoliceRecordScore.clean
        XCTAssertEqual(gs.maxLoan(currentWorth: 1_000_000), 25_000)
    }

    func testGameStateGetLoanMutatesSave() {
        let gs = GameState()
        gs.save.policeRecordScore = PoliceRecordScore.clean
        gs.credits = 0
        gs.debt = 0
        let borrowed = gs.getLoan(amount: 10_000, currentWorth: 50_000)
        // maxLoan for 50_000 worth at clean record = 5_000.
        XCTAssertEqual(borrowed, 5_000)
        XCTAssertEqual(gs.credits, 5_000)
        XCTAssertEqual(gs.debt, 5_000)
    }

    func testGameStatePayBackMutatesSave() {
        let gs = GameState()
        gs.credits = 2_000
        gs.debt = 1_500
        let paid = gs.payBack(amount: 99_999)
        XCTAssertEqual(paid, 1_500)
        XCTAssertEqual(gs.credits, 500)
        XCTAssertEqual(gs.debt, 0)
    }
}
