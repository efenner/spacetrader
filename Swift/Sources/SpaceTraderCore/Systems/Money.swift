// Derived from Space Trader by Pieter Spronck, GPLv2.
//
// Port of Src/Money.c. Two operations:
//   - CurrentWorth(): total net worth = ship price + credits − debt
//     + moon. We take `currentShipPrice` as a parameter so Money
//     doesn't depend on ShipPrice (Step 10); the convenience method
//     `currentWorth()` on `GameState` will supply it once Step 10
//     lands.
//   - PayInterest(): daily interest = max(1, debt / 10), paid first
//     from credits, then added back to debt if the commander is broke.

import Foundation

public enum MoneySystem {

    /// Port of `CurrentWorth` in Src/Money.c:46-49. The C code calls
    /// `CurrentShipPrice(false)` under the hood; this version takes it
    /// as a parameter so the function has no hidden dependency on the
    /// ShipPrice system.
    @inlinable public static func currentWorth(
        shipPrice: Int,
        credits: Int,
        debt: Int,
        moonBought: Bool
    ) -> Int {
        shipPrice + credits - debt + (moonBought ? Money.costMoon : 0)
    }

    /// Port of `PayInterest` in Src/Money.c:55-70. Mutates its
    /// arguments in place.
    ///   - Parameters:
    ///     - credits: commander's cash; decreases if they can cover
    ///       the interest payment.
    ///     - debt: commander's outstanding loan; grows when credits
    ///       can't cover the interest.
    public static func payInterest(credits: inout Int, debt: inout Int) {
        guard debt > 0 else { return }
        let incDebt = max(1, debt / 10)
        if credits > incDebt {
            credits -= incDebt
        } else {
            debt += (incDebt - credits)
            credits = 0
        }
    }
}

public extension GameState {
    /// Fold the moon bonus and pending ship-resale price into a single
    /// "net worth" number. Callers pass in the current ship price
    /// because that depends on the ShipPrice system (Step 10); until
    /// that lands, tests can hand in a synthetic value.
    func currentWorth(shipPrice: Int) -> Int {
        MoneySystem.currentWorth(
            shipPrice: shipPrice,
            credits: save.credits,
            debt: save.debt,
            moonBought: save.moonBought
        )
    }

    /// Apply one day of loan interest. Internally we pull the two
    /// fields into locals before handing them to the interest routine
    /// — taking `&save.credits` and `&save.debt` together would create
    /// overlapping exclusive accesses to `save`.
    func payInterest() {
        var credits = save.credits
        var debt = save.debt
        MoneySystem.payInterest(credits: &credits, debt: &debt)
        save.credits = credits
        save.debt = debt
    }
}
