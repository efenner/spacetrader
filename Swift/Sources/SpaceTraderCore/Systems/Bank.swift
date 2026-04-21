// Derived from Space Trader by Pieter Spronck, GPLv2.
//
// Port of Src/Bank.c lines 40-71. Three operations:
//   - maxLoan(policeRecordScore:currentWorth:): the cap on new
//     borrowing. Below `CLEANSCORE` the bank only trusts you with
//     500 cr; at/above, you get 10% of net worth rounded down to the
//     nearest 500, clamped to [1000, 25000].
//   - getLoan(amount:maxLoan:credits:debt:): issue a loan, bounded by
//     `maxLoan − debt` so the commander never exceeds their cap.
//   - payBack(amount:credits:debt:): repay, bounded by the smaller of
//     debt and credits. Mirrors Bank.c:65-71 exactly — the form
//     handler passes 99999 for "pay everything" and the min/min pair
//     does the right thing.
//
// `maxLoan` takes `currentWorth` as a parameter so Bank, like Money,
// has no hidden dependency on the ShipPrice system (Step 10). The
// GameState forwarder will compose the two once ShipPrice lands.

import Foundation

public enum BankSystem {

    /// Port of `MaxLoan` in Bank.c:40-44. Commanders with a record
    /// worse than Clean can only borrow 500 cr; others get 10% of net
    /// worth rounded down to the nearest 500, clamped to [1000, 25000].
    /// The double division matches the C expression exactly:
    /// `((CurrentWorth() / 10L) / 500L) * 500L`.
    public static func maxLoan(policeRecordScore: Int, currentWorth: Int) -> Int {
        guard policeRecordScore >= PoliceRecordScore.clean else { return 500 }
        let tenth = currentWorth / 10
        let stepped = (tenth / 500) * 500
        return min(25_000, max(1_000, stepped))
    }

    /// Port of `GetLoan` in Bank.c:50-57. Returns the amount actually
    /// borrowed (which can be less than `amount` if the commander is
    /// near their cap). Mutates `credits` and `debt` in place.
    ///
    /// Note: Bank.c's UI gates on `Debt >= MaxLoan()` before calling
    /// this (Bank.c:153), so in normal play `amount` is positive and
    /// `maxLoan − debt` is non-negative. We preserve the raw math in
    /// case a future caller needs the same behavior; callers that want
    /// UI-level protection should check the gate themselves.
    @discardableResult
    public static func getLoan(
        amount: Int,
        maxLoan: Int,
        credits: inout Int,
        debt: inout Int
    ) -> Int {
        let borrowable = min(maxLoan - debt, amount)
        credits += borrowable
        debt += borrowable
        return borrowable
    }

    /// Port of `PayBack` in Bank.c:63-71. Returns the amount actually
    /// paid back. Repayment is capped first by outstanding debt, then
    /// by cash on hand, so passing `99999` as the C "pay everything"
    /// button does drains exactly the right amount.
    @discardableResult
    public static func payBack(
        amount: Int,
        credits: inout Int,
        debt: inout Int
    ) -> Int {
        var paid = min(debt, amount)
        paid = min(paid, credits)
        credits -= paid
        debt -= paid
        return paid
    }
}

public extension GameState {
    /// Compute the lending cap using the commander's current police
    /// record and the provided net worth. Callers pass `currentWorth`
    /// because `CurrentShipPrice` lives in the ShipPrice system
    /// (Step 10); until that lands tests supply a synthetic value.
    func maxLoan(currentWorth: Int) -> Int {
        BankSystem.maxLoan(
            policeRecordScore: save.policeRecordScore,
            currentWorth: currentWorth
        )
    }

    /// Borrow up to `amount` credits; returns how much was actually
    /// borrowed. Fields are copied to locals before mutation so we
    /// don't take two overlapping exclusive accesses to `save` (same
    /// pattern payInterest/buyFuel use).
    @discardableResult
    func getLoan(amount: Int, currentWorth: Int) -> Int {
        let cap = BankSystem.maxLoan(
            policeRecordScore: save.policeRecordScore,
            currentWorth: currentWorth
        )
        var credits = save.credits
        var debt = save.debt
        let borrowed = BankSystem.getLoan(
            amount: amount,
            maxLoan: cap,
            credits: &credits,
            debt: &debt
        )
        save.credits = credits
        save.debt = debt
        return borrowed
    }

    /// Repay up to `amount` credits; returns how much actually moved.
    @discardableResult
    func payBack(amount: Int) -> Int {
        var credits = save.credits
        var debt = save.debt
        let paid = BankSystem.payBack(
            amount: amount,
            credits: &credits,
            debt: &debt
        )
        save.credits = credits
        save.debt = debt
        return paid
    }
}
