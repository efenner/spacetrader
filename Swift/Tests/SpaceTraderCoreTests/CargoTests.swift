// Derived from Space Trader by Pieter Spronck, GPLv2.

import XCTest
@testable import SpaceTraderCore

final class CargoTests: XCTestCase {

    // MARK: capacity accounting

    func testTotalCargoBaysBaselineForGnat() {
        // Gnat base cargoBays = 15 per ShipTypes.all[1].
        let ship = Ship(type: 1)
        XCTAssertEqual(CargoSystem.totalCargoBays(ship: ship), 15)
    }

    func testTotalCargoBaysStacksExtraBaysGadget() {
        var ship = Ship(type: 1)
        ship.gadget[0] = GadgetIndex.extraBays
        ship.gadget[1] = GadgetIndex.extraBays
        XCTAssertEqual(CargoSystem.totalCargoBays(ship: ship), 15 + 10)
    }

    func testFilledCargoBaysSumsArray() {
        var ship = Ship(type: 1)
        ship.cargo[TradeItemIndex.water] = 3
        ship.cargo[TradeItemIndex.food] = 5
        XCTAssertEqual(CargoSystem.filledCargoBays(ship: ship), 8)
    }

    // MARK: buyCargo — refusal paths

    func testBuyCargoRefusesWhenDebtTooLarge() {
        var ship = Ship(type: 1)
        var credits = 10_000
        var buying = Array(repeating: 0, count: GameLimits.maxTradeItem)
        var qty    = Array(repeating: 10, count: GameLimits.maxTradeItem)

        let bought = CargoSystem.buyCargo(
            index: 0, amount: 1, buyPrice: 10, debt: Money.debtTooLarge + 1,
            ship: &ship, credits: &credits, buyingPrice: &buying, systemQty: &qty
        )
        XCTAssertEqual(bought, 0)
        XCTAssertEqual(credits, 10_000)
        XCTAssertEqual(ship.cargo[0], 0)
    }

    func testBuyCargoRefusesWhenNotSold() {
        var ship = Ship(type: 1)
        var credits = 10_000
        var buying = Array(repeating: 0, count: GameLimits.maxTradeItem)
        var qty    = Array(repeating: 0, count: GameLimits.maxTradeItem) // no stock

        let bought = CargoSystem.buyCargo(
            index: 0, amount: 5, buyPrice: 10, debt: 0,
            ship: &ship, credits: &credits, buyingPrice: &buying, systemQty: &qty
        )
        XCTAssertEqual(bought, 0)
    }

    func testBuyCargoRefusesWhenBuyPriceZero() {
        var ship = Ship(type: 1)
        var credits = 10_000
        var buying = Array(repeating: 0, count: GameLimits.maxTradeItem)
        var qty    = Array(repeating: 10, count: GameLimits.maxTradeItem)

        let bought = CargoSystem.buyCargo(
            index: 0, amount: 5, buyPrice: 0, debt: 0, // price 0 → not sold
            ship: &ship, credits: &credits, buyingPrice: &buying, systemQty: &qty
        )
        XCTAssertEqual(bought, 0)
    }

    func testBuyCargoRefusesWhenNoEmptyBays() {
        var ship = Ship(type: 1)
        ship.cargo[TradeItemIndex.water] = 15  // Gnat is full
        var credits = 10_000
        var buying = Array(repeating: 0, count: GameLimits.maxTradeItem)
        var qty    = Array(repeating: 10, count: GameLimits.maxTradeItem)

        let bought = CargoSystem.buyCargo(
            index: 1, amount: 5, buyPrice: 10, debt: 0,
            ship: &ship, credits: &credits, buyingPrice: &buying, systemQty: &qty
        )
        XCTAssertEqual(bought, 0)
    }

    func testBuyCargoRefusesWhenCantAffordOne() {
        var ship = Ship(type: 1)
        var credits = 9  // one unit costs 10
        var buying = Array(repeating: 0, count: GameLimits.maxTradeItem)
        var qty    = Array(repeating: 10, count: GameLimits.maxTradeItem)

        let bought = CargoSystem.buyCargo(
            index: 0, amount: 5, buyPrice: 10, debt: 0,
            ship: &ship, credits: &credits, buyingPrice: &buying, systemQty: &qty
        )
        XCTAssertEqual(bought, 0)
        XCTAssertEqual(credits, 9)
    }

    // MARK: buyCargo — happy + boundary paths

    func testBuyCargoClampsAcrossAllThreeCaps() {
        // Amount 100, sys qty 8, empty bays 15, can afford 10 → min is 8.
        var ship = Ship(type: 1)
        var credits = 100
        var buying = Array(repeating: 0, count: GameLimits.maxTradeItem)
        var qty    = Array(repeating: 0, count: GameLimits.maxTradeItem)
        qty[0] = 8

        let bought = CargoSystem.buyCargo(
            index: 0, amount: 100, buyPrice: 10, debt: 0,
            ship: &ship, credits: &credits, buyingPrice: &buying, systemQty: &qty
        )
        XCTAssertEqual(bought, 8)
        XCTAssertEqual(ship.cargo[0], 8)
        XCTAssertEqual(credits, 100 - 8 * 10)
        XCTAssertEqual(buying[0], 80)
        XCTAssertEqual(qty[0], 0)
    }

    // MARK: sellCargo

    func testSellCargoProratesBuyingPrice() {
        var ship = Ship(type: 1)
        ship.cargo[0] = 10
        var credits = 0
        var buying = Array(repeating: 0, count: GameLimits.maxTradeItem)
        buying[0] = 500   // paid 50 cr per unit on average

        let sold = CargoSystem.sellCargo(
            index: 0, amount: 4, sellPrice: 60,
            ship: &ship, credits: &credits, buyingPrice: &buying
        )
        XCTAssertEqual(sold, 4)
        XCTAssertEqual(ship.cargo[0], 6)
        XCTAssertEqual(credits, 240)
        // 500 * (10-4)/10 = 300 → C integer div preserved.
        XCTAssertEqual(buying[0], 300)
    }

    func testSellCargoRefusesWhenNothingInHold() {
        var ship = Ship(type: 1)
        var credits = 0
        var buying = Array(repeating: 0, count: GameLimits.maxTradeItem)
        XCTAssertEqual(
            CargoSystem.sellCargo(
                index: 3, amount: 1, sellPrice: 10,
                ship: &ship, credits: &credits, buyingPrice: &buying
            ),
            0
        )
    }

    func testSellCargoRefusesWhenBuyerNotInterested() {
        var ship = Ship(type: 1)
        ship.cargo[0] = 5
        var credits = 0
        var buying = Array(repeating: 0, count: GameLimits.maxTradeItem)
        XCTAssertEqual(
            CargoSystem.sellCargo(
                index: 0, amount: 5, sellPrice: 0,
                ship: &ship, credits: &credits, buyingPrice: &buying
            ),
            0
        )
    }

    // MARK: GameState forwarders

    func testGameStateBuyCargoMutatesCurrentSystem() {
        let gs = GameState()
        gs.save.mercenary[0].curSystem = 0
        gs.save.solarSystem[0].qty[TradeItemIndex.water] = 10
        gs.save.buyPrice[TradeItemIndex.water] = 25
        gs.credits = 100
        gs.save.ship = Ship(type: 1) // empty Gnat, 15 bays

        let bought = gs.buyCargo(index: TradeItemIndex.water, amount: 3)
        XCTAssertEqual(bought, 3)
        XCTAssertEqual(gs.save.ship.cargo[TradeItemIndex.water], 3)
        XCTAssertEqual(gs.credits, 25)
        XCTAssertEqual(gs.save.solarSystem[0].qty[TradeItemIndex.water], 7)
        XCTAssertEqual(gs.save.buyingPrice[TradeItemIndex.water], 75)
    }

    func testGameStateSellCargoForwards() {
        let gs = GameState()
        gs.save.ship = Ship(type: 1)
        gs.save.ship.cargo[TradeItemIndex.food] = 5
        gs.save.buyingPrice[TradeItemIndex.food] = 200
        gs.save.sellPrice[TradeItemIndex.food] = 50
        gs.credits = 0

        let sold = gs.sellCargo(index: TradeItemIndex.food, amount: 2)
        XCTAssertEqual(sold, 2)
        XCTAssertEqual(gs.credits, 100)
        XCTAssertEqual(gs.save.ship.cargo[TradeItemIndex.food], 3)
    }
}
