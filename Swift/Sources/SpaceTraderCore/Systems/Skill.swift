// Derived from Space Trader by Pieter Spronck, GPLv2.
//
// Port of Src/Skill.c. Phase-1 covers the four effective-skill
// aggregators (`pilotSkill`, `fighterSkill`, `traderSkill`,
// `engineerSkill`), the difficulty adapter they run through, and the
// three equipment predicates (`hasGadget`, `hasShield`, `hasWeapon`).
//
// NthLowestSkill / IncreaseRandomSkill / DecreaseRandomSkill /
// TonicTweakRandomSkill / RandomSkill / RecalculateBuyPrices /
// RecalculateSellPrices are all skill-related but belong to Encounter,
// SpecialEvent, and Cargo flows we haven't ported yet; they stay
// deferred until those systems land.

import Foundation

public enum SkillSystem {

    // MARK: Equipment predicates

    /// Port of `HasGadget` from Src/Skill.c:387-400. Walks the
    /// `MAXGADGET` slots and returns true if any holds the queried
    /// gadget index; `-1` slots are skipped.
    public static func hasGadget(ship: Ship, gadget: Int) -> Bool {
        ship.gadget.contains(gadget)
    }

    /// Port of `HasShield` from Src/Skill.c:405-418.
    public static func hasShield(ship: Ship, shield: Int) -> Bool {
        ship.shield.contains(shield)
    }

    /// Port of `HasWeapon` from Src/Skill.c:424-437. When
    /// `exactCompare` is false, any weapon whose index is strictly
    /// *greater* than the queried one is also a match — this is how
    /// "has at least a Beam Laser" queries work in the C code.
    public static func hasWeapon(ship: Ship, weapon: Int, exactCompare: Bool) -> Bool {
        for slot in ship.weapon where slot >= 0 {
            if slot == weapon { return true }
            if slot > weapon && !exactCompare { return true }
        }
        return false
    }

    // MARK: Skill aggregators

    /// Port of `PilotSkill` in Src/Skill.c:305-326. Takes the max of
    /// every crew member's pilot rating, then adds the gadget bonuses
    /// (Navigating System + Cloaking Device, which stack), then runs
    /// the result through `adaptDifficulty`.
    public static func pilotSkill(
        ship: Ship,
        mercenaries: [CrewMember],
        difficulty: Int
    ) -> Int {
        var m = maxCrewSkill(ship: ship, mercenaries: mercenaries) { $0.pilot }
        if hasGadget(ship: ship, gadget: GadgetIndex.navigatingSystem) {
            m += SkillIndex.skillBonus
        }
        if hasGadget(ship: ship, gadget: GadgetIndex.cloakingDevice) {
            m += SkillIndex.cloakBonus
        }
        return adaptDifficulty(level: m, difficulty: difficulty)
    }

    /// Port of `FighterSkill` in Src/Skill.c:281-300. Adds SKILLBONUS
    /// when the ship has a Targeting System.
    public static func fighterSkill(
        ship: Ship,
        mercenaries: [CrewMember],
        difficulty: Int
    ) -> Int {
        var m = maxCrewSkill(ship: ship, mercenaries: mercenaries) { $0.fighter }
        if hasGadget(ship: ship, gadget: GadgetIndex.targetingSystem) {
            m += SkillIndex.skillBonus
        }
        return adaptDifficulty(level: m, difficulty: difficulty)
    }

    /// Port of `TraderSkill` in Src/Skill.c:117-136. Trader has no
    /// gadget bonus, but the Jarek quest (state >= 2) grants +1 once
    /// the ambassador has been delivered.
    public static func traderSkill(
        ship: Ship,
        mercenaries: [CrewMember],
        difficulty: Int,
        jarekStatus: Int
    ) -> Int {
        var m = maxCrewSkill(ship: ship, mercenaries: mercenaries) { $0.trader }
        if jarekStatus >= 2 {
            m += 1
        }
        return adaptDifficulty(level: m, difficulty: difficulty)
    }

    /// Port of `EngineerSkill` in Src/Skill.c:331-350. Adds SKILLBONUS
    /// when the ship has an Auto-Repair System.
    public static func engineerSkill(
        ship: Ship,
        mercenaries: [CrewMember],
        difficulty: Int
    ) -> Int {
        var m = maxCrewSkill(ship: ship, mercenaries: mercenaries) { $0.engineer }
        if hasGadget(ship: ship, gadget: GadgetIndex.autoRepairSystem) {
            m += SkillIndex.skillBonus
        }
        return adaptDifficulty(level: m, difficulty: difficulty)
    }

    // MARK: Difficulty modifier

    /// Port of `AdaptDifficulty` in Src/Skill.c:355-363. On Beginner /
    /// Easy every effective skill is bumped by 1; on Impossible it's
    /// knocked down by 1 but floored at 1; Normal and Hard pass the
    /// raw skill through.
    public static func adaptDifficulty(level: Int, difficulty: Int) -> Int {
        switch difficulty {
        case Difficulty.beginner, Difficulty.easy:
            return level + 1
        case Difficulty.impossible:
            return max(1, level - 1)
        default:
            return level
        }
    }

    // MARK: Internal

    /// Max of a per-crew-member skill, walking `ship.crew` the same
    /// way the C loop does: slot 0 is the seed, slots 1..<MAXCREW
    /// break on `-1`. `ship.crew[0]` is assumed to reference a valid
    /// mercenary, matching the C invariant.
    private static func maxCrewSkill(
        ship: Ship,
        mercenaries: [CrewMember],
        skill: (CrewMember) -> Int
    ) -> Int {
        var m = skill(mercenaries[ship.crew[0]])
        for i in 1..<GameLimits.maxCrew {
            if ship.crew[i] < 0 { break }
            let s = skill(mercenaries[ship.crew[i]])
            if s > m { m = s }
        }
        return m
    }
}

public extension GameState {
    /// Effective pilot skill for the player's ship — roster max plus
    /// gadget stacks, then difficulty-adjusted.
    func pilotSkill() -> Int {
        SkillSystem.pilotSkill(
            ship: save.ship,
            mercenaries: save.mercenary,
            difficulty: save.difficulty
        )
    }

    func fighterSkill() -> Int {
        SkillSystem.fighterSkill(
            ship: save.ship,
            mercenaries: save.mercenary,
            difficulty: save.difficulty
        )
    }

    func traderSkill() -> Int {
        SkillSystem.traderSkill(
            ship: save.ship,
            mercenaries: save.mercenary,
            difficulty: save.difficulty,
            jarekStatus: save.jarekStatus
        )
    }

    func engineerSkill() -> Int {
        SkillSystem.engineerSkill(
            ship: save.ship,
            mercenaries: save.mercenary,
            difficulty: save.difficulty
        )
    }

    // MARK: Zero-arg conveniences across Money/Bank/ShipPrice
    //
    // Now that Skill has landed, the three systems that previously
    // asked callers to hand in `shipPrice` / `currentWorth` /
    // skill triples can compose themselves.

    /// Net worth folding in the current ship's resale price. The
    /// parametrized variant (`currentWorth(shipPrice:)`) stays available
    /// for tests that want to drive the calculation with a synthetic
    /// ship value.
    func currentWorth() -> Int {
        currentWorth(shipPrice: currentShipPrice(forInsurance: false))
    }

    /// Lending cap against the current net worth.
    func maxLoan() -> Int {
        maxLoan(currentWorth: currentWorth())
    }

    /// Value an encounter ship by filling in its pilot/engineer/
    /// fighter skills from the game's mercenary roster — the C code
    /// uses `Sh->Crew[0]`'s skills for each encounter ship too.
    func enemyShipPrice(ship: Ship) -> Int {
        ShipPriceSystem.enemyShipPrice(
            ship: ship,
            pilotSkill: SkillSystem.pilotSkill(
                ship: ship, mercenaries: save.mercenary, difficulty: save.difficulty
            ),
            engineerSkill: SkillSystem.engineerSkill(
                ship: ship, mercenaries: save.mercenary, difficulty: save.difficulty
            ),
            fighterSkill: SkillSystem.fighterSkill(
                ship: ship, mercenaries: save.mercenary, difficulty: save.difficulty
            )
        )
    }
}
