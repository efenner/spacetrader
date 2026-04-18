// Derived from Space Trader by Pieter Spronck, GPLv2.
//
// Port of the top-level `#define`s in Src/spacetrader.h. Grouped under
// `enum` namespaces so call sites read like `GameLimits.maxTradeItem`
// rather than `MAXTRADEITEM`. Raw indices are kept as Int because they
// round-trip through tables and save data unchanged from the C code.
//
// Anything Palm-specific (appFileCreator, romVersion, sysMakeROMVersion)
// is intentionally dropped.

import Foundation

public enum GameLimits {
    public static let maxTradeItem    = 10
    public static let maxShipType     = 10
    public static let extraShips      = 5     // non-buyable ships appended after MAXSHIPTYPE
    public static let maxWeaponType   = 3
    public static let extraWeapons    = 1
    public static let maxShieldType   = 2
    public static let extraShields    = 1
    public static let maxGadgetType   = 5
    public static let extraGadgets    = 1
    public static let maxWeapon       = 3     // slots on ship
    public static let maxShield       = 3
    public static let maxGadget       = 3
    public static let maxCrew         = 3
    public static let maxCrewMember   = 31
    public static let nameLen         = 20
    public static let maxSkill        = 10
    public static let maxSolarSystem  = 120
    public static let maxWormhole     = 6
    public static let maxPolitics     = 17
    public static let maxTechLevel    = 8
    public static let maxActivity     = 8
    public static let maxStatus       = 8
    public static let maxDifficulty   = 5
    public static let maxResources    = 13
    public static let maxSize         = 5
    public static let maxPoliceRecord = 10
    public static let maxReputation   = 9
    public static let maxRange        = 20
    public static let maxTribbles     = 100_000
    public static let maxHighScore    = 3
    public static let maxSpecialEvent = 37
}

public enum Galaxy {
    public static let width  = 150
    public static let height = 110
    public static let minDistance     = 6
    public static let closeDistance   = 13
    public static let wormholeDistance = 3
}

public enum SkillIndex {
    public static let pilot    = 1
    public static let fighter  = 2
    public static let trader   = 3
    public static let engineer = 4
    public static let skillBonus = 3   // gadget bonus that stacks on top of crew skill
    public static let cloakBonus = 2
    public static let maxSkillType = 4
}

public enum TradeItemIndex {
    public static let water     = 0
    public static let furs      = 1
    public static let food      = 2
    public static let ore       = 3
    public static let games     = 4
    public static let firearms  = 5
    public static let medicine  = 6
    public static let machinery = 7
    public static let narcotics = 8
    public static let robots    = 9
}

public enum SystemStatusIndex {
    public static let uneventful    = 0
    public static let war           = 1
    public static let plague        = 2
    public static let drought       = 3
    public static let boredom       = 4
    public static let cold          = 5
    public static let cropFailure   = 6
    public static let lackOfWorkers = 7
}

public enum Difficulty {
    public static let beginner   = 0
    public static let easy       = 1
    public static let normal     = 2
    public static let hard       = 3
    public static let impossible = 4
}

public enum Resource {
    public static let none            = 0
    public static let mineralRich     = 1
    public static let mineralPoor     = 2
    public static let desert          = 3
    public static let lotsOfWater     = 4
    public static let richSoil        = 5
    public static let poorSoil        = 6
    public static let richFauna       = 7
    public static let lifeless        = 8
    public static let weirdMushrooms  = 9
    public static let lotsOfHerbs     = 10
    public static let artistic        = 11
    public static let warlike         = 12
}

public enum WeaponIndex {
    public static let pulseLaser     = 0
    public static let beamLaser      = 1
    public static let militaryLaser  = 2
    public static let morganLaser    = 3

    public static let pulsePower     = 15
    public static let beamPower      = 25
    public static let militaryPower  = 35
    public static let morganPower    = 85
}

public enum ShieldIndex {
    public static let energy     = 0
    public static let reflective = 1
    public static let lightning  = 2

    public static let energyPower     = 100
    public static let reflectivePower = 200
    public static let lightningPower  = 350
}

public enum GadgetIndex {
    public static let extraBays        = 0
    public static let autoRepairSystem = 1
    public static let navigatingSystem = 2
    public static let targetingSystem  = 3
    public static let cloakingDevice   = 4
    public static let fuelCompactor    = 5
}

/// Score thresholds that determine a commander's printed police-record tier.
public enum PoliceRecordScore {
    public static let psychopath = -70
    public static let villain    = -30
    public static let criminal   = -10
    public static let dubious    = -5
    public static let clean      = 0
    public static let lawful     = 5
    public static let trusted    = 10
    public static let helper     = 25
    public static let hero       = 75
}

/// Kill-count thresholds for combat reputation.
public enum ReputationScore {
    public static let harmless        = 0
    public static let mostlyHarmless  = 10
    public static let poor            = 20
    public static let average         = 40
    public static let aboveAverage    = 80
    public static let competent       = 150
    public static let dangerous       = 300
    public static let deadly          = 600
    public static let elite           = 1500
}

/// Bookkeeping deltas applied to `PoliceRecordScore` on specific actions.
public enum PoliceScoreDelta {
    public static let attackPolice      = -3
    public static let killPolice        = -6
    public static let caughtWithWild    = -4
    public static let attackTrader      = -2
    public static let plunderTrader     = -2
    public static let killTrader        = -4
    public static let attackPirate      = 0
    public static let killPirate        = 1
    public static let plunderPirate     = -1
    public static let trafficking       = -1
    public static let fleeFromInspection = -2
    public static let takeMarieNarcotics = -4
}

public enum Money {
    public static let costMoon         = 500_000
    public static let debtWarning      = 75_000
    public static let debtTooLarge     = 100_000
    public static let maxDigits        = 8
    public static let maxPriceDigits   = 5
    public static let maxQtyDigits     = 3
}

public enum Highscore {
    public static let killed = 0
    public static let retired = 1
    public static let moon = 2
}

/// Odds drawn in 1000 for the very-rare-encounter and trade-in-orbit rolls.
public enum EncounterOdds {
    public static let veryRarePer1000    = 5
    public static let tradeInOrbitPer1000 = 100
    public static let maxVeryRareEncounter = 6
    public static let fabricRipInitialProbability = 25
}
