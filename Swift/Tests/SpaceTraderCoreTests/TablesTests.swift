// Derived from Space Trader by Pieter Spronck, GPLv2.

import XCTest
@testable import SpaceTraderCore

final class TablesTests: XCTestCase {

    // MARK: Length invariants against Constants.swift / Src/spacetrader.h

    func testTableLengthsMatchGameLimits() {
        XCTAssertEqual(TradeItems.all.count,       GameLimits.maxTradeItem)
        XCTAssertEqual(ShipTypes.all.count,        GameLimits.maxShipType + GameLimits.extraShips)
        XCTAssertEqual(Weapons.all.count,          GameLimits.maxWeaponType + GameLimits.extraWeapons)
        XCTAssertEqual(Shields.all.count,          GameLimits.maxShieldType + GameLimits.extraShields)
        XCTAssertEqual(Gadgets.all.count,          GameLimits.maxGadgetType + GameLimits.extraGadgets)
        XCTAssertEqual(PoliticsTable.all.count,    GameLimits.maxPolitics)
        XCTAssertEqual(StatusLabels.all.count,     GameLimits.maxStatus)
        XCTAssertEqual(ActivityLabels.all.count,   GameLimits.maxActivity)
        XCTAssertEqual(DifficultyLabels.all.count, GameLimits.maxDifficulty)
        XCTAssertEqual(ResourceLabels.all.count,   GameLimits.maxResources)
        XCTAssertEqual(SystemSizeLabels.all.count, GameLimits.maxSize)
        XCTAssertEqual(TechLevelLabels.all.count,  GameLimits.maxTechLevel)
        XCTAssertEqual(PoliceRecords.all.count,    GameLimits.maxPoliceRecord)
        XCTAssertEqual(Reputations.all.count,      GameLimits.maxReputation)
        XCTAssertEqual(MercenaryNames.all.count,   GameLimits.maxCrewMember)
        XCTAssertEqual(SystemNames.all.count,      GameLimits.maxSolarSystem)
    }

    // MARK: Name-index parity with the C `#define`s

    func testTradeItemIndicesMatchNames() {
        XCTAssertEqual(TradeItems.all[TradeItemIndex.water].name,     "Water")
        XCTAssertEqual(TradeItems.all[TradeItemIndex.furs].name,      "Furs")
        XCTAssertEqual(TradeItems.all[TradeItemIndex.food].name,      "Food")
        XCTAssertEqual(TradeItems.all[TradeItemIndex.ore].name,       "Ore")
        XCTAssertEqual(TradeItems.all[TradeItemIndex.games].name,     "Games")
        XCTAssertEqual(TradeItems.all[TradeItemIndex.firearms].name,  "Firearms")
        XCTAssertEqual(TradeItems.all[TradeItemIndex.medicine].name,  "Medicine")
        XCTAssertEqual(TradeItems.all[TradeItemIndex.machinery].name, "Machines")
        XCTAssertEqual(TradeItems.all[TradeItemIndex.narcotics].name, "Narcotics")
        XCTAssertEqual(TradeItems.all[TradeItemIndex.robots].name,    "Robots")
    }

    func testShipTypeFleaMatchesCDefaults() {
        let flea = ShipTypes.all[0]
        XCTAssertEqual(flea.name, "Flea")
        XCTAssertEqual(flea.cargoBays, 10)
        XCTAssertEqual(flea.fuelTanks, GameLimits.maxRange)
        XCTAssertEqual(flea.price, 2_000)
    }

    func testPoliceRecordsAreMonotonicallyNonDecreasing() {
        // The C code walks the array bottom-up to print the name; this only
        // works if min-scores are sorted ascending.
        let scores = PoliceRecords.all.map(\.minScore)
        XCTAssertEqual(scores, scores.sorted())
    }

    func testReputationsAreMonotonicallyNonDecreasing() {
        let scores = Reputations.all.map(\.minScore)
        XCTAssertEqual(scores, scores.sorted())
    }

    func testPoliticsKnownWantedGoods() {
        // Spot-check a couple of rows against Src/Global.c:335-354.
        let capitalism = PoliticsTable.all[1]
        XCTAssertEqual(capitalism.name, "Capitalist State")
        XCTAssertEqual(capitalism.wanted, TradeItemIndex.ore)

        let anarchy = PoliticsTable.all[0]
        XCTAssertEqual(anarchy.name, "Anarchy")
        XCTAssertEqual(anarchy.wanted, TradeItemIndex.food)
        XCTAssertFalse(anarchy.drugsOK == false, "Anarchy allows drugs")
    }

    func testSystemNamesAreAlphabetical() {
        // Src/Global.c stores them sorted; keep it that way so binary search
        // and the chart label generator stay predictable.
        let names = SystemNames.all
        XCTAssertEqual(names, names.sorted())
        XCTAssertEqual(names.first, "Acamar")
        XCTAssertEqual(names.last, "Zuul")
    }

    func testMercenaryCommanderSlotIsDefaultName() {
        XCTAssertEqual(MercenaryNames.all[0], MercenaryNames.defaultCommanderName)
        XCTAssertEqual(MercenaryNames.all.last, "Zeethibal")
    }
}
