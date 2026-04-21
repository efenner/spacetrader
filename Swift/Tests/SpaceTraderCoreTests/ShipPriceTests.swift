// Derived from Space Trader by Pieter Spronck, GPLv2.

import XCTest
@testable import SpaceTraderCore

final class ShipPriceTests: XCTestCase {

    // Shared Gnat baseline: price 10_000, fuelTanks 14, costOfFuel 2,
    // hullStrength 100, repairCosts 1. Pulse laser: price 2_000.
    private func gnatWithPulseLaser(hull: Int = 100, fuel: Int = 14, tribbles: Int = 0) -> Ship {
        var s = Ship(type: 1, fuel: fuel, hull: hull, tribbles: tribbles)
        s.weapon[0] = WeaponIndex.pulseLaser
        return s
    }

    // MARK: getHullStrength

    func testGetHullStrengthBase() {
        let gnat = Ship(type: 1)
        XCTAssertEqual(ShipPriceSystem.getHullStrength(ship: gnat, scarabStatus: 0), 100)
    }

    func testGetHullStrengthScarabUpgrade() {
        let gnat = Ship(type: 1)
        XCTAssertEqual(
            ShipPriceSystem.getHullStrength(ship: gnat, scarabStatus: 3),
            100 + ShipBalance.upgradedHull
        )
    }

    func testGetHullStrengthIntermediateScarabStateIsNoUpgrade() {
        // Only state 3 grants the bonus.
        let gnat = Ship(type: 1)
        XCTAssertEqual(ShipPriceSystem.getHullStrength(ship: gnat, scarabStatus: 2), 100)
    }

    // MARK: baseSellPrice

    func testBaseSellPriceOfEmptySlotIsZero() {
        XCTAssertEqual(ShipPriceSystem.baseSellPrice(slot: -1, price: 10_000), 0)
    }

    func testBaseSellPriceIsThreeQuarters() {
        XCTAssertEqual(ShipPriceSystem.baseSellPrice(slot: 0, price: 2_000), 1_500)
    }

    func testBaseSellPriceRoundsDown() {
        // (5 * 3) / 4 = 3, integer division.
        XCTAssertEqual(ShipPriceSystem.baseSellPrice(slot: 0, price: 5), 3)
    }

    // MARK: currentShipPriceWithoutCargo — fresh / damaged / tribbles

    func testCurrentShipPriceWithoutCargoFreshGnat() {
        // 7_500 (3/4 of 10_000) + 1_500 (3/4 of pulse laser) = 9_000.
        let ship = gnatWithPulseLaser()
        XCTAssertEqual(
            ShipPriceSystem.currentShipPriceWithoutCargo(
                ship: ship, forInsurance: false, scarabStatus: 0
            ),
            9_000
        )
    }

    func testCurrentShipPriceWithoutCargoDamagedAndLowFuel() {
        // hull 50 → repair deduction (100-50)*1 = 50.
        // fuel 7 → fuel deduction (14-7)*2 = 14.
        // 7_500 − 50 − 14 + 1_500 = 8_936.
        let ship = gnatWithPulseLaser(hull: 50, fuel: 7)
        XCTAssertEqual(
            ShipPriceSystem.currentShipPriceWithoutCargo(
                ship: ship, forInsurance: false, scarabStatus: 0
            ),
            8_936
        )
    }

    func testCurrentShipPriceWithoutCargoTribblesQuarterBase() {
        // Tribbles drop the base to 2_500; equipment still at full 3/4.
        let ship = gnatWithPulseLaser(tribbles: 1)
        XCTAssertEqual(
            ShipPriceSystem.currentShipPriceWithoutCargo(
                ship: ship, forInsurance: false, scarabStatus: 0
            ),
            2_500 + 1_500
        )
    }

    func testCurrentShipPriceWithoutCargoInsuranceIgnoresTribbles() {
        // Same ship, but an insurance quote ignores the tribble penalty.
        let ship = gnatWithPulseLaser(tribbles: 1)
        XCTAssertEqual(
            ShipPriceSystem.currentShipPriceWithoutCargo(
                ship: ship, forInsurance: true, scarabStatus: 0
            ),
            9_000
        )
    }

    func testCurrentShipPriceWithoutCargoScarabRaisesRepairDeduction() {
        // Scarab bumps hullStrength to 150; hull is still 100, so
        // repair deduction (150-100)*1 = 50.
        let ship = gnatWithPulseLaser()
        XCTAssertEqual(
            ShipPriceSystem.currentShipPriceWithoutCargo(
                ship: ship, forInsurance: false, scarabStatus: 3
            ),
            9_000 - 50
        )
    }

    func testCurrentShipPriceWithoutCargoSumsAllSlots() {
        // Put the pulse laser in slot 1 (leaving slot 0 empty) and
        // confirm the loop still counts it.
        var ship = Ship(type: 1, fuel: 14, hull: 100)
        ship.weapon[1] = WeaponIndex.pulseLaser
        XCTAssertEqual(
            ShipPriceSystem.currentShipPriceWithoutCargo(
                ship: ship, forInsurance: false, scarabStatus: 0
            ),
            9_000
        )
    }

    func testCurrentShipPriceWithoutCargoCountsShieldsAndGadgets() {
        // Energy shield 5_000 → 3_750; extra cargo bays 2_500 → 1_875.
        var ship = gnatWithPulseLaser()
        ship.shield[0] = ShieldIndex.energy
        ship.gadget[0] = GadgetIndex.extraBays
        XCTAssertEqual(
            ShipPriceSystem.currentShipPriceWithoutCargo(
                ship: ship, forInsurance: false, scarabStatus: 0
            ),
            9_000 + 3_750 + 1_875
        )
    }

    // MARK: currentShipPrice — cargo roll-in

    func testCurrentShipPriceAddsBuyingPriceSum() {
        let ship = gnatWithPulseLaser()
        var prices = Array(repeating: 0, count: GameLimits.maxTradeItem)
        prices[0] = 100
        prices[5] = 250
        XCTAssertEqual(
            ShipPriceSystem.currentShipPrice(
                ship: ship,
                forInsurance: false,
                scarabStatus: 0,
                buyingPrice: prices
            ),
            9_000 + 350
        )
    }

    // MARK: enemyShipPrice

    func testEnemyShipPriceScalesBySkillSum() {
        // Gnat 10_000 + pulse laser 2_000 = 12_000 at full price.
        // (2*5 + 5 + 3*5) = 30, factor 30/60 = 1/2 → 6_000.
        let ship = gnatWithPulseLaser()
        XCTAssertEqual(
            ShipPriceSystem.enemyShipPrice(
                ship: ship, pilotSkill: 5, engineerSkill: 5, fighterSkill: 5
            ),
            6_000
        )
    }

    func testEnemyShipPriceZeroSkillsIsZero() {
        let ship = gnatWithPulseLaser()
        XCTAssertEqual(
            ShipPriceSystem.enemyShipPrice(
                ship: ship, pilotSkill: 0, engineerSkill: 0, fighterSkill: 0
            ),
            0
        )
    }

    func testEnemyShipPriceIgnoresGadgets() {
        // A cloaking device (100_000) must not show up in the sum.
        var ship = gnatWithPulseLaser()
        ship.gadget[0] = GadgetIndex.cloakingDevice
        XCTAssertEqual(
            ShipPriceSystem.enemyShipPrice(
                ship: ship, pilotSkill: 5, engineerSkill: 5, fighterSkill: 5
            ),
            6_000
        )
    }

    // MARK: GameState forwards

    func testGameStateGetHullStrengthReflectsScarabStatus() {
        let gs = GameState()
        gs.save.ship = Ship(type: 1)
        XCTAssertEqual(gs.getHullStrength(), 100)
        gs.save.scarabStatus = 3
        XCTAssertEqual(gs.getHullStrength(), 150)
    }

    func testGameStateCurrentShipPriceWithoutCargo() {
        let gs = GameState()
        gs.save.ship = gnatWithPulseLaser()
        XCTAssertEqual(gs.currentShipPriceWithoutCargo(forInsurance: false), 9_000)
    }

    func testGameStateCurrentShipPriceFoldsBuyingPrice() {
        let gs = GameState()
        gs.save.ship = gnatWithPulseLaser()
        var prices = Array(repeating: 0, count: GameLimits.maxTradeItem)
        prices[2] = 500
        gs.save.buyingPrice = prices
        XCTAssertEqual(gs.currentShipPrice(forInsurance: false), 9_500)
    }
}
