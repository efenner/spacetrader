// Derived from Space Trader by Pieter Spronck, GPLv2.

import XCTest
@testable import SpaceTraderCore

final class ModelsTests: XCTestCase {

    // MARK: Ship

    func testStarterGnatMatchesGlobalCDefaults() {
        let gnat = Ship.starterGnat
        XCTAssertEqual(gnat.type, 1)
        XCTAssertEqual(gnat.cargo.count, GameLimits.maxTradeItem)
        XCTAssertEqual(gnat.cargo, Array(repeating: 0, count: GameLimits.maxTradeItem))
        XCTAssertEqual(gnat.weapon[0], WeaponIndex.pulseLaser)
        XCTAssertEqual(gnat.weapon[1], -1)
        XCTAssertEqual(gnat.shield,  Array(repeating: -1, count: GameLimits.maxShield))
        XCTAssertEqual(gnat.gadget,  Array(repeating: -1, count: GameLimits.maxGadget))
        XCTAssertEqual(gnat.crew[0], 0)     // commander on board
        XCTAssertEqual(gnat.fuel, 14)
        XCTAssertEqual(gnat.hull, 100)
        XCTAssertEqual(gnat.tribbles, 0)
    }

    func testShipArraysAreFixedLengthOnInit() {
        let s = Ship(type: 0)
        XCTAssertEqual(s.cargo.count,           GameLimits.maxTradeItem)
        XCTAssertEqual(s.weapon.count,          GameLimits.maxWeapon)
        XCTAssertEqual(s.shield.count,          GameLimits.maxShield)
        XCTAssertEqual(s.shieldStrength.count,  GameLimits.maxShield)
        XCTAssertEqual(s.gadget.count,          GameLimits.maxGadget)
        XCTAssertEqual(s.crew.count,            GameLimits.maxCrew)
    }

    // MARK: CrewMember / SolarSystem defaults

    func testCrewMemberDefaultsAreZero() {
        let merc = CrewMember(nameIndex: 5)
        XCTAssertEqual(merc.nameIndex, 5)
        XCTAssertEqual(merc.pilot, 0)
        XCTAssertEqual(merc.fighter, 0)
        XCTAssertEqual(merc.trader, 0)
        XCTAssertEqual(merc.engineer, 0)
        XCTAssertEqual(merc.curSystem, 0)
    }

    func testSolarSystemDefaultSpecialIsMinusOne() {
        let sys = SolarSystem(nameIndex: 0)
        XCTAssertEqual(sys.special, -1)
        XCTAssertEqual(sys.qty.count, GameLimits.maxTradeItem)
        XCTAssertFalse(sys.visited)
    }

    // MARK: SaveGame composite

    func testDefaultSaveGameHasExpectedShape() {
        let sg = SaveGame()
        XCTAssertEqual(sg.credits, 1_000)
        XCTAssertEqual(sg.debt, 0)
        XCTAssertEqual(sg.nameCommander, MercenaryNames.defaultCommanderName)
        XCTAssertEqual(sg.mercenary.count, GameLimits.maxCrewMember + 1)
        XCTAssertEqual(sg.solarSystem.count, GameLimits.maxSolarSystem)
        XCTAssertEqual(sg.wormhole.count, GameLimits.maxWormhole)
        XCTAssertEqual(sg.buyPrice.count, GameLimits.maxTradeItem)
        XCTAssertEqual(sg.shipPrice.count, GameLimits.maxShipType)
        XCTAssertEqual(sg.difficulty, Difficulty.normal)
        XCTAssertEqual(sg.fabricRipProbability, EncounterOdds.fabricRipInitialProbability)
        // Commander sits in slot 0 of the roster.
        XCTAssertEqual(sg.mercenary[0].nameIndex, 0)
    }

    func testSaveGameJSONRoundTripIsByteIdentical() throws {
        // Populate a handful of non-default fields so the round-trip
        // actually exercises the encoder/decoder paths.
        var sg = SaveGame()
        sg.credits = 12_345
        sg.debt = 500
        sg.days = 42
        sg.ship.cargo[TradeItemIndex.firearms] = 7
        sg.ship.weapon[1] = WeaponIndex.beamLaser
        sg.solarSystem[0].visited = true
        sg.solarSystem[0].qty[TradeItemIndex.water] = 99
        sg.wormhole[0] = 50
        sg.mercenary[1].pilot = 9

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data1 = try encoder.encode(sg)

        let decoded = try JSONDecoder().decode(SaveGame.self, from: data1)
        let data2 = try encoder.encode(decoded)

        XCTAssertEqual(data1, data2)
        XCTAssertEqual(decoded.credits, 12_345)
        XCTAssertEqual(decoded.ship.cargo[TradeItemIndex.firearms], 7)
        XCTAssertEqual(decoded.ship.weapon[1], WeaponIndex.beamLaser)
        XCTAssertTrue(decoded.solarSystem[0].visited)
        XCTAssertEqual(decoded.solarSystem[0].qty[TradeItemIndex.water], 99)
        XCTAssertEqual(decoded.wormhole[0], 50)
        XCTAssertEqual(decoded.mercenary[1].pilot, 9)
    }

    // MARK: Leaf models Codable

    func testHighScoreAndSpecialEventRoundTrip() throws {
        let hs = HighScore(name: "Jameson", status: Highscore.moon, days: 200, worth: 9_000_000, difficulty: Difficulty.hard)
        let se = SpecialEvent(title: "Dragonfly Destroyed", questStringID: 0, price: 0, occurrence: 0, justAMessage: true)

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]

        let hsData = try encoder.encode(hs)
        let seData = try encoder.encode(se)

        XCTAssertEqual(try JSONDecoder().decode(HighScore.self, from: hsData), hs)
        XCTAssertEqual(try JSONDecoder().decode(SpecialEvent.self, from: seData), se)
    }
}
