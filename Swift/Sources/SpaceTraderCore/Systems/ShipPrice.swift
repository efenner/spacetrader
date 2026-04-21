// Derived from Space Trader by Pieter Spronck, GPLv2.
//
// Port of Src/ShipPrice.c plus the pair of helpers the pricing math
// relies on — `GetHullStrength` (Src/Shipyard.c:117-123) and
// `BaseSellPrice` (Src/Cargo.c:1120-1123). All equipment slots use
// `-1` for empty in the Swift port, matching the C convention, so the
// `>= 0` guards port directly.
//
// Skill-dependent helpers (`enemyShipPrice`) take the three skill
// values as parameters so this file has no dependency on the Skill
// system (Step 11). Once Step 11 lands, GameState convenience methods
// will fill them in.

import Foundation

public enum ShipPriceSystem {

    /// Port of `GetHullStrength` in Src/Shipyard.c:117-123. The Scarab
    /// quest (state 3) grants a fixed hull bonus; in all other states
    /// the ship type's base HullStrength is returned unmodified.
    public static func getHullStrength(ship: Ship, scarabStatus: Int) -> Int {
        let base = ShipTypes.all[ship.type].hullStrength
        return scarabStatus == 3 ? base + ShipBalance.upgradedHull : base
    }

    /// Port of `BaseSellPrice` in Src/Cargo.c:1120-1123. Equipment
    /// sells for three-quarters of its purchase price; empty slots
    /// (`slot == -1`) return zero.
    public static func baseSellPrice(slot: Int, price: Int) -> Int {
        slot >= 0 ? (price * 3) / 4 : 0
    }

    /// Port of `CurrentShipPriceWithoutCargo` in Src/ShipPrice.c:72-96.
    ///
    /// The trade-in value is three-quarters of the ship type's base
    /// price — except when Tribbles have infested the ship and we are
    /// not computing an insurance figure, in which case it drops to a
    /// quarter. From that we subtract outstanding repair and fuel
    /// costs, then add three-quarters of the price of each fitted
    /// weapon, shield, and gadget.
    ///
    /// Note: the C code uses the ship type's base fuel tank count —
    /// *not* `GetFuelTanks(ship)` — in the fuel-refill deduction, so a
    /// ship with a Fuel Compactor topping above the base tank count
    /// actually adds a small amount to the trade-in value. That's a
    /// pre-existing quirk; we preserve it for parity.
    public static func currentShipPriceWithoutCargo(
        ship: Ship,
        forInsurance: Bool,
        scarabStatus: Int
    ) -> Int {
        let st = ShipTypes.all[ship.type]

        // 3/4 of base price, slashed to 1/4 if tribbles are on board.
        let tribbleFactor = (ship.tribbles > 0 && !forInsurance) ? 1 : 3
        var price = (st.price * tribbleFactor) / 4

        // Repair and refuel deductions.
        price -= (getHullStrength(ship: ship, scarabStatus: scarabStatus) - ship.hull) * st.repairCosts
        price -= (st.fuelTanks - FuelSystem.getFuel(ship: ship)) * st.costOfFuel

        // 3/4 of the purchase price of each fitted weapon, shield,
        // gadget. `baseSellPrice` already handles the >= 0 guard but
        // we keep the explicit check to mirror the C loop shape.
        for i in 0..<GameLimits.maxWeapon where ship.weapon[i] >= 0 {
            price += baseSellPrice(slot: ship.weapon[i], price: Weapons.all[ship.weapon[i]].price)
        }
        for i in 0..<GameLimits.maxShield where ship.shield[i] >= 0 {
            price += baseSellPrice(slot: ship.shield[i], price: Shields.all[ship.shield[i]].price)
        }
        for i in 0..<GameLimits.maxGadget where ship.gadget[i] >= 0 {
            price += baseSellPrice(slot: ship.gadget[i], price: Gadgets.all[ship.gadget[i]].price)
        }

        return price
    }

    /// Port of `CurrentShipPrice` in Src/ShipPrice.c:102-112. Same as
    /// without-cargo plus the sum of `buyingPrice[]` for each of the
    /// ten trade goods currently in the hold. The C code reads the
    /// global `BuyingPrice[]`; the Swift port takes it as a parameter
    /// so this function stays pure.
    public static func currentShipPrice(
        ship: Ship,
        forInsurance: Bool,
        scarabStatus: Int,
        buyingPrice: [Int]
    ) -> Int {
        var price = currentShipPriceWithoutCargo(
            ship: ship,
            forInsurance: forInsurance,
            scarabStatus: scarabStatus
        )
        for i in 0..<GameLimits.maxTradeItem {
            price += buyingPrice[i]
        }
        return price
    }

    /// Port of `EnemyShipPrice` in Src/ShipPrice.c:49-67. Values an
    /// encounter ship at **full** base price + full equipment price
    /// (no three-quarter haircut, no repair/refuel deductions, no
    /// gadget contribution), then scales by a skill-weighted factor
    /// of `(2*pilot + engineer + 3*fighter) / 60`.
    ///
    /// The skill arguments are taken as ints rather than computed
    /// inside so this module has no dependency on the Skill system
    /// (Step 11). The GameState convenience that lands with Step 11
    /// will fill them from the ship's crew.
    public static func enemyShipPrice(
        ship: Ship,
        pilotSkill: Int,
        engineerSkill: Int,
        fighterSkill: Int
    ) -> Int {
        var price = ShipTypes.all[ship.type].price
        for i in 0..<GameLimits.maxWeapon where ship.weapon[i] >= 0 {
            price += Weapons.all[ship.weapon[i]].price
        }
        for i in 0..<GameLimits.maxShield where ship.shield[i] >= 0 {
            price += Shields.all[ship.shield[i]].price
        }
        // Gadgets are intentionally skipped; their value is folded
        // into the skill multiplier.
        return price * (2 * pilotSkill + engineerSkill + 3 * fighterSkill) / 60
    }
}

public extension GameState {
    /// Hull strength at this moment; respects the Scarab quest reward.
    func getHullStrength() -> Int {
        ShipPriceSystem.getHullStrength(ship: save.ship, scarabStatus: save.scarabStatus)
    }

    /// Trade-in value of the current ship with fittings, no cargo.
    /// `forInsurance` mirrors the C flag: insurance quotes ignore
    /// tribble infestation so the commander can't farm an insurance
    /// windfall by buying out a cheap tribble ship.
    func currentShipPriceWithoutCargo(forInsurance: Bool) -> Int {
        ShipPriceSystem.currentShipPriceWithoutCargo(
            ship: save.ship,
            forInsurance: forInsurance,
            scarabStatus: save.scarabStatus
        )
    }

    /// Trade-in value including cargo in the hold, priced at the
    /// current system's buying prices.
    func currentShipPrice(forInsurance: Bool) -> Int {
        ShipPriceSystem.currentShipPrice(
            ship: save.ship,
            forInsurance: forInsurance,
            scarabStatus: save.scarabStatus,
            buyingPrice: save.buyingPrice
        )
    }
}
