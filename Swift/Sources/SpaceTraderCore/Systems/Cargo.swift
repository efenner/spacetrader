// Derived from Space Trader by Pieter Spronck, GPLv2.
//
// Port of the buy/sell core of `Src/Cargo.c`. The C functions fold
// alert presentation, UI redraw, and mutation into one routine; the
// Swift port separates the math (here) from the view (in
// `iOSApp/Screens/BuyCargoView.swift`) so callers can decide what to
// do with a refused trade — show an alert, disable a button, etc.
//
// Phase-1 scope:
//   - `totalCargoBays` / `filledCargoBays` for capacity accounting.
//   - `buyCargo` with the four C guards (debt, qty, free bays, cash).
//   - `sellCargo` with the `SELLCARGO` branch only — dump and
//     jettison belong to post-combat and encounter flows that ship
//     in later phases.
//
// Quest-driven modifiers (Japori disease shrinks bays, Reactor quest
// shrinks bays, LeaveEmpty reserves bays for plot items) are
// deferred; `totalCargoBays` here returns the ship-type baseline
// plus Extra Cargo Bays gadgets, matching the "normal play" path
// through `Cargo.c:1016-1032`.

import Foundation

public enum CargoSystem {

    /// Port of `TotalCargoBays` (Cargo.c:1016-1032) minus the quest
    /// modifiers. Each fitted Extra Cargo Bays gadget adds 5 bays.
    public static func totalCargoBays(ship: Ship) -> Int {
        var bays = ShipTypes.all[ship.type].cargoBays
        for slot in ship.gadget where slot == GadgetIndex.extraBays {
            bays += 5
        }
        return bays
    }

    /// Port of `FilledCargoBays` (Cargo.c:1038-1047). Every unit of
    /// cargo occupies one bay.
    public static func filledCargoBays(ship: Ship) -> Int {
        ship.cargo.reduce(0, +)
    }

    /// Port of `BuyCargo(Index, Amount, DisplayInfo)` from
    /// Cargo.c:858-901. Returns the number of units actually
    /// purchased (0 on any of the refusal paths). Mutates the ship,
    /// credits, cost-basis, and system stock in place so callers
    /// can't forget one of the four.
    @discardableResult
    public static func buyCargo(
        index: Int,
        amount: Int,
        buyPrice: Int,
        debt: Int,
        ship: inout Ship,
        credits: inout Int,
        buyingPrice: inout [Int],
        systemQty: inout [Int]
    ) -> Int {
        if debt > Money.debtTooLarge { return 0 }
        if systemQty[index] <= 0 || buyPrice <= 0 { return 0 }

        let emptyBays = totalCargoBays(ship: ship) - filledCargoBays(ship: ship)
        if emptyBays <= 0 { return 0 }
        if credits < buyPrice { return 0 }

        var toBuy = min(amount, systemQty[index])
        toBuy = min(toBuy, emptyBays)
        toBuy = min(toBuy, credits / buyPrice)
        if toBuy <= 0 { return 0 }

        ship.cargo[index] += toBuy
        credits -= toBuy * buyPrice
        buyingPrice[index] += toBuy * buyPrice
        systemQty[index] -= toBuy
        return toBuy
    }

    /// Port of the `SELLCARGO` branch of `SellCargo(Index, Amount,
    /// Operation)` from Cargo.c:908-981. Returns the number of units
    /// actually sold. Preserves the cost-basis prorating in
    /// Cargo.c:944 — `buyingPrice[i]` is scaled down by the fraction
    /// of stock remaining, so the running "what did I pay for this"
    /// total stays consistent.
    @discardableResult
    public static func sellCargo(
        index: Int,
        amount: Int,
        sellPrice: Int,
        ship: inout Ship,
        credits: inout Int,
        buyingPrice: inout [Int]
    ) -> Int {
        if ship.cargo[index] <= 0 { return 0 }
        if sellPrice <= 0 { return 0 }

        let toSell = min(amount, ship.cargo[index])
        if toSell <= 0 { return 0 }

        buyingPrice[index] = buyingPrice[index] * (ship.cargo[index] - toSell) / ship.cargo[index]
        ship.cargo[index] -= toSell
        credits += toSell * sellPrice
        return toSell
    }
}

public extension GameState {
    func totalCargoBays() -> Int { CargoSystem.totalCargoBays(ship: save.ship) }
    func filledCargoBays() -> Int { CargoSystem.filledCargoBays(ship: save.ship) }

    /// Buy `amount` units of trade item `index` from the docked
    /// system at the cached `buyPrice`, mutating ship cargo,
    /// credits, the cost-basis tracker, and the system's remaining
    /// stock. Returns the amount actually transferred.
    @discardableResult
    func buyCargo(index: Int, amount: Int) -> Int {
        var ship = save.ship
        var credits = save.credits
        var buying = save.buyingPrice
        var system = currentSystem
        var qty = system.qty

        let bought = CargoSystem.buyCargo(
            index: index,
            amount: amount,
            buyPrice: save.buyPrice[index],
            debt: save.debt,
            ship: &ship,
            credits: &credits,
            buyingPrice: &buying,
            systemQty: &qty
        )

        save.ship = ship
        save.credits = credits
        save.buyingPrice = buying
        system.qty = qty
        currentSystem = system
        return bought
    }

    /// Sell `amount` units of trade item `index` at the current
    /// system's `sellPrice`. Preserves the C cost-basis proration.
    @discardableResult
    func sellCargo(index: Int, amount: Int) -> Int {
        var ship = save.ship
        var credits = save.credits
        var buying = save.buyingPrice

        let sold = CargoSystem.sellCargo(
            index: index,
            amount: amount,
            sellPrice: save.sellPrice[index],
            ship: &ship,
            credits: &credits,
            buyingPrice: &buying
        )

        save.ship = ship
        save.credits = credits
        save.buyingPrice = buying
        return sold
    }
}
