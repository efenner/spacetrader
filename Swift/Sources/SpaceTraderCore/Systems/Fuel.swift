// Derived from Space Trader by Pieter Spronck, GPLv2.
//
// Port of Src/Fuel.c. Three operations:
//   - getFuelTanks(ship:): tank capacity, bumped to 18 parsecs if the
//     ship has a Fuel Compactor gadget.
//   - getFuel(ship:): fuel on board, clamped to current capacity.
//   - buyFuel(amount:credits:ship:): spend up to `amount` credits on
//     fuel, clamped to capacity and to credits in hand. Matches the
//     two-step division in Fuel.c:79 — an odd credit can't buy half a
//     parsec, so rounding the player out of fractional pennies is
//     intentional.

import Foundation

public enum FuelSystem {

    /// Capacity the ship can hold in parsecs. Fuel Compactor fixes it
    /// to 18 independent of ship type (Fuel.c:50-53).
    public static func getFuelTanks(ship: Ship) -> Int {
        if hasGadget(ship, GadgetIndex.fuelCompactor) {
            return 18
        }
        return ShipTypes.all[ship.type].fuelTanks
    }

    /// Fuel on board, clamped to capacity (Fuel.c:59-62). Prevents a
    /// ship that lost its compactor from reporting 18 when its new
    /// capacity is lower.
    public static func getFuel(ship: Ship) -> Int {
        min(ship.fuel, getFuelTanks(ship: ship))
    }

    /// Port of `BuyFuel(int)` from Fuel.c:68-83. Returns the
    /// potentially-reduced amount actually spent; mutates the ship
    /// and credit pool in place.
    @discardableResult
    public static func buyFuel(amount: Int, credits: inout Int, ship: inout Ship) -> Int {
        let costPerTank = ShipTypes.all[ship.type].costOfFuel
        let spaceLeft = getFuelTanks(ship: ship) - getFuel(ship: ship)
        let maxFuel = spaceLeft * costPerTank

        var amt = amount
        if amt > maxFuel { amt = maxFuel }
        if amt > credits { amt = credits }

        // C performs integer division, so e.g. amt=9 with cost=5
        // buys 1 parsec and leaves 4 credits on the table. We
        // preserve that.
        let parsecs = amt / max(costPerTank, 1)
        ship.fuel += parsecs
        credits -= parsecs * costPerTank
        return parsecs * costPerTank
    }

    /// Port of `HasGadget` used by getFuelTanks. The full HasGadget
    /// helper will move to a shared file once more systems need it;
    /// scoping it here avoids prematurely expanding the surface area.
    @usableFromInline internal static func hasGadget(_ ship: Ship, _ gadget: Int) -> Bool {
        ship.gadget.contains(gadget)
    }
}

public extension GameState {
    func getFuelTanks() -> Int { FuelSystem.getFuelTanks(ship: save.ship) }
    func getFuel() -> Int      { FuelSystem.getFuel(ship: save.ship) }

    /// Spend up to `amount` credits on fuel; mutates credits + ship.
    /// Returns the amount actually spent so the UI can echo it.
    @discardableResult
    func buyFuel(amount: Int) -> Int {
        var credits = save.credits
        var ship = save.ship
        let spent = FuelSystem.buyFuel(amount: amount, credits: &credits, ship: &ship)
        save.credits = credits
        save.ship = ship
        return spent
    }
}
