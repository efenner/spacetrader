// Derived from Space Trader by Pieter Spronck, GPLv2.

import XCTest
@testable import SpaceTraderCore

final class FuelTests: XCTestCase {

    // MARK: Tank capacity

    func testTankCapacityDefaultsToShipTypeTanks() {
        let flea = Ship(type: 0)          // Flea: 20-tank (matches MAXRANGE)
        let gnat = Ship(type: 1)          // Gnat: 14-tank
        XCTAssertEqual(FuelSystem.getFuelTanks(ship: flea), ShipTypes.all[0].fuelTanks)
        XCTAssertEqual(FuelSystem.getFuelTanks(ship: gnat), 14)
    }

    func testFuelCompactorBumpsCapacityTo18() {
        var ship = Ship(type: 1)  // Gnat — 14 tanks normally
        ship.gadget[0] = GadgetIndex.fuelCompactor
        XCTAssertEqual(FuelSystem.getFuelTanks(ship: ship), 18)
    }

    // MARK: getFuel clamp

    func testGetFuelClampsToCapacity() {
        var ship = Ship(type: 1)
        ship.fuel = 100  // nonsense reading above capacity
        XCTAssertEqual(FuelSystem.getFuel(ship: ship), 14) // Gnat cap
    }

    // MARK: buyFuel

    func testBuyFuelClampsToCapacity() {
        var ship = Ship(type: 1, fuel: 10) // Gnat has 14-tank, so 4 parsecs free
        var credits = 10_000
        let spent = FuelSystem.buyFuel(amount: 10_000, credits: &credits, ship: &ship)
        // 4 parsecs * 2 credits/parsec = 8
        XCTAssertEqual(ship.fuel, 14)
        XCTAssertEqual(spent, 8)
        XCTAssertEqual(credits, 10_000 - 8)
    }

    func testBuyFuelClampsToCredits() {
        var ship = Ship(type: 1, fuel: 0) // Empty Gnat
        var credits = 5
        let spent = FuelSystem.buyFuel(amount: 100, credits: &credits, ship: &ship)
        // 5 credits / 2 per-parsec = 2 parsecs, costing 4; 1 credit left on the table.
        XCTAssertEqual(ship.fuel, 2)
        XCTAssertEqual(credits, 1)
        XCTAssertEqual(spent, 4)
    }

    func testBuyFuelAmountZeroIsNoop() {
        var ship = Ship(type: 1, fuel: 5)
        var credits = 1_000
        let spent = FuelSystem.buyFuel(amount: 0, credits: &credits, ship: &ship)
        XCTAssertEqual(ship.fuel, 5)
        XCTAssertEqual(credits, 1_000)
        XCTAssertEqual(spent, 0)
    }

    func testBuyFuelWithCompactorFills18() {
        var ship = Ship(type: 1, fuel: 0)
        ship.gadget[0] = GadgetIndex.fuelCompactor
        var credits = 10_000
        FuelSystem.buyFuel(amount: 10_000, credits: &credits, ship: &ship)
        XCTAssertEqual(ship.fuel, 18)
        XCTAssertEqual(credits, 10_000 - 18 * 2)
    }

    // MARK: GameState forwards

    func testGameStateBuyFuelUpdatesSave() {
        let gs = GameState()
        gs.save.ship = Ship(type: 1, fuel: 0)
        gs.credits = 1_000
        let spent = gs.buyFuel(amount: 1_000)
        XCTAssertEqual(gs.save.ship.fuel, 14)
        XCTAssertEqual(gs.credits, 1_000 - 14 * 2)
        XCTAssertEqual(spent, 28)
    }
}
