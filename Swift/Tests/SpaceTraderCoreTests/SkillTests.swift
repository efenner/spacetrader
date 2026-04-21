// Derived from Space Trader by Pieter Spronck, GPLv2.

import XCTest
@testable import SpaceTraderCore

final class SkillTests: XCTestCase {

    // A fresh default ship with one crew slot (commander at index 0).
    private func gnat() -> Ship { Ship(type: 1, fuel: 14, hull: 100) }

    // MARK: hasGadget / hasShield / hasWeapon

    func testHasGadgetTrueWhenFitted() {
        var ship = gnat()
        ship.gadget[1] = GadgetIndex.targetingSystem
        XCTAssertTrue(SkillSystem.hasGadget(ship: ship, gadget: GadgetIndex.targetingSystem))
    }

    func testHasGadgetFalseWhenAbsent() {
        let ship = gnat()
        XCTAssertFalse(SkillSystem.hasGadget(ship: ship, gadget: GadgetIndex.cloakingDevice))
    }

    func testHasShield() {
        var ship = gnat()
        ship.shield[0] = ShieldIndex.reflective
        XCTAssertTrue(SkillSystem.hasShield(ship: ship, shield: ShieldIndex.reflective))
        XCTAssertFalse(SkillSystem.hasShield(ship: ship, shield: ShieldIndex.energy))
    }

    func testHasWeaponExactCompareOnly() {
        var ship = gnat()
        ship.weapon[0] = WeaponIndex.beamLaser
        // Beam laser is fitted; asking for "pulse laser exactly" → false.
        XCTAssertFalse(SkillSystem.hasWeapon(ship: ship, weapon: WeaponIndex.pulseLaser, exactCompare: true))
        // Asking for "pulse laser or better" → true, because beam > pulse.
        XCTAssertTrue(SkillSystem.hasWeapon(ship: ship, weapon: WeaponIndex.pulseLaser, exactCompare: false))
        // Asking for beam exactly → true.
        XCTAssertTrue(SkillSystem.hasWeapon(ship: ship, weapon: WeaponIndex.beamLaser, exactCompare: true))
    }

    // MARK: crew-max aggregation

    func testPilotSkillTakesCrewMaxPlusGadgetStack() {
        // Commander at mercenary[0] pilot=5; crew mate at mercenary[1] pilot=8.
        var mercs = SaveGame.defaultMercenaryRoster()
        mercs[0] = CrewMember(nameIndex: 0, pilot: 5)
        mercs[1] = CrewMember(nameIndex: 1, pilot: 8)

        var ship = gnat()
        ship.crew[0] = 0
        ship.crew[1] = 1
        ship.gadget[0] = GadgetIndex.navigatingSystem   // +3
        ship.gadget[1] = GadgetIndex.cloakingDevice     // +2

        // Normal difficulty passes the skill through unmodified.
        let s = SkillSystem.pilotSkill(
            ship: ship,
            mercenaries: mercs,
            difficulty: Difficulty.normal
        )
        XCTAssertEqual(s, 8 + SkillIndex.skillBonus + SkillIndex.cloakBonus)
    }

    func testFighterSkillTargetingSystemBonus() {
        var mercs = SaveGame.defaultMercenaryRoster()
        mercs[0] = CrewMember(nameIndex: 0, fighter: 4)

        var ship = gnat()
        ship.crew[0] = 0
        ship.gadget[0] = GadgetIndex.targetingSystem

        XCTAssertEqual(
            SkillSystem.fighterSkill(ship: ship, mercenaries: mercs, difficulty: Difficulty.normal),
            4 + SkillIndex.skillBonus
        )
    }

    func testTraderSkillJarekAmbassadorBonus() {
        var mercs = SaveGame.defaultMercenaryRoster()
        mercs[0] = CrewMember(nameIndex: 0, trader: 6)

        var ship = gnat()
        ship.crew[0] = 0

        // Jarek status 0 → no bonus.
        XCTAssertEqual(
            SkillSystem.traderSkill(
                ship: ship, mercenaries: mercs,
                difficulty: Difficulty.normal, jarekStatus: 0
            ),
            6
        )
        // Jarek status 2 (delivered) → +1.
        XCTAssertEqual(
            SkillSystem.traderSkill(
                ship: ship, mercenaries: mercs,
                difficulty: Difficulty.normal, jarekStatus: 2
            ),
            7
        )
    }

    func testEngineerSkillAutoRepairBonus() {
        var mercs = SaveGame.defaultMercenaryRoster()
        mercs[0] = CrewMember(nameIndex: 0, engineer: 3)

        var ship = gnat()
        ship.crew[0] = 0
        ship.gadget[0] = GadgetIndex.autoRepairSystem

        XCTAssertEqual(
            SkillSystem.engineerSkill(ship: ship, mercenaries: mercs, difficulty: Difficulty.normal),
            3 + SkillIndex.skillBonus
        )
    }

    func testCrewWalkStopsAtFirstEmptySlot() {
        // Put a high-pilot merc in slot 2 but leave slot 1 empty (-1).
        // The C loop breaks on the first -1, so the high-pilot merc
        // must be ignored and slot 0's pilot should win.
        var mercs = SaveGame.defaultMercenaryRoster()
        mercs[0] = CrewMember(nameIndex: 0, pilot: 4)
        mercs[5] = CrewMember(nameIndex: 5, pilot: 10)

        var ship = gnat()
        ship.crew[0] = 0
        ship.crew[1] = -1   // vacancy
        ship.crew[2] = 5    // ignored because [1] is empty

        XCTAssertEqual(
            SkillSystem.pilotSkill(ship: ship, mercenaries: mercs, difficulty: Difficulty.normal),
            4
        )
    }

    // MARK: adaptDifficulty

    func testAdaptDifficultyBeginnerBumps() {
        XCTAssertEqual(SkillSystem.adaptDifficulty(level: 5, difficulty: Difficulty.beginner), 6)
        XCTAssertEqual(SkillSystem.adaptDifficulty(level: 5, difficulty: Difficulty.easy), 6)
    }

    func testAdaptDifficultyNormalHardPassThrough() {
        XCTAssertEqual(SkillSystem.adaptDifficulty(level: 5, difficulty: Difficulty.normal), 5)
        XCTAssertEqual(SkillSystem.adaptDifficulty(level: 5, difficulty: Difficulty.hard), 5)
    }

    func testAdaptDifficultyImpossibleSubtractsButFloorsAtOne() {
        XCTAssertEqual(SkillSystem.adaptDifficulty(level: 5, difficulty: Difficulty.impossible), 4)
        XCTAssertEqual(SkillSystem.adaptDifficulty(level: 1, difficulty: Difficulty.impossible), 1)
        XCTAssertEqual(SkillSystem.adaptDifficulty(level: 0, difficulty: Difficulty.impossible), 1)
    }

    // MARK: GameState forwards

    func testGameStateSkillForwardsThreadDifficulty() {
        let gs = GameState()
        gs.save.mercenary[0] = CrewMember(nameIndex: 0, pilot: 5, fighter: 5, trader: 5, engineer: 5)
        gs.save.ship = gnat()
        gs.save.ship.crew[0] = 0

        gs.save.difficulty = Difficulty.beginner
        XCTAssertEqual(gs.pilotSkill(), 6)
        XCTAssertEqual(gs.fighterSkill(), 6)
        XCTAssertEqual(gs.traderSkill(), 6)
        XCTAssertEqual(gs.engineerSkill(), 6)
    }

    func testGameStateTraderSkillReadsJarekStatus() {
        let gs = GameState()
        gs.save.mercenary[0] = CrewMember(nameIndex: 0, trader: 7)
        gs.save.ship = gnat()
        gs.save.ship.crew[0] = 0
        gs.save.jarekStatus = 2
        XCTAssertEqual(gs.traderSkill(), 8)
    }

    // MARK: Zero-arg Money/Bank/ShipPrice conveniences now composable

    func testGameStateCurrentWorthZeroArgFoldsShipPrice() {
        let gs = GameState()
        // Fresh Gnat with pulse laser: currentShipPrice should equal 9_000
        // (3/4 of 10_000 base + 3/4 of 2_000 pulse laser). No cargo set.
        var ship = gnat()
        ship.weapon[0] = WeaponIndex.pulseLaser
        gs.save.ship = ship
        gs.credits = 500
        gs.debt = 200
        // currentWorth() = shipPrice + credits − debt = 9_000 + 300 = 9_300.
        XCTAssertEqual(gs.currentWorth(), 9_300)
    }

    func testGameStateMaxLoanZeroArgComposesCurrentWorth() {
        let gs = GameState()
        var ship = gnat()
        ship.weapon[0] = WeaponIndex.pulseLaser
        gs.save.ship = ship
        gs.credits = 1_000
        // currentWorth = 9_000 + 1_000 = 10_000
        // maxLoan: 10_000/10 = 1_000; /500*500 = 1_000; clamp [1000,25000] → 1_000.
        XCTAssertEqual(gs.maxLoan(), 1_000)
    }

    func testGameStateEnemyShipPriceFillsSkillsFromRoster() {
        let gs = GameState()
        gs.save.mercenary[0] = CrewMember(nameIndex: 0, pilot: 5, fighter: 5, trader: 5, engineer: 5)
        var enemy = gnat()
        enemy.weapon[0] = WeaponIndex.pulseLaser
        enemy.crew[0] = 0
        // base 10_000 + 2_000 = 12_000. Skills (2*5 + 5 + 3*5) = 30 → 12_000*30/60 = 6_000.
        XCTAssertEqual(gs.enemyShipPrice(ship: enemy), 6_000)
    }
}
