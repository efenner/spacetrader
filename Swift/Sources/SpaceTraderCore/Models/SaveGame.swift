// Derived from Space Trader by Pieter Spronck, GPLv2.
//
// Port of `SAVEGAMETYPE` from Src/DataTypes.h:180-255. This is the
// persistence schema — everything the save file needs to restore a
// game. Palm-specific fields (`SharePreferences`, `RectangularButtonsOn`,
// `ForFutureUse`) are intentionally dropped; the JSON format we emit
// is not interchangeable with the original `.pdb` files (see PLAN.md).
//
// Layout order follows `SAVEGAMETYPE` so a future reviewer can diff
// against the C header field-for-field.

import Foundation

public struct SaveGame: Codable, Sendable {

    // MARK: Money / core state
    public var credits: Int
    public var debt: Int
    public var days: Int

    // MARK: Navigation + UI
    public var warpSystem: Int
    public var selectedShipType: Int
    public var galacticChartSystem: Int
    public var curForm: Int

    // MARK: Per-trade-item price cache
    /// Size = `MAXTRADEITEM`. Cached for UI snappiness; regenerated on load.
    public var buyPrice: [Int]
    public var sellPrice: [Int]
    /// Actual price paid when the player bought each commodity; used by
    /// the profit-display logic.
    public var buyingPrice: [Int]
    /// Size = `MAXSHIPTYPE`. Ship-yard price cache.
    public var shipPrice: [Int]

    // MARK: Reputation / records
    public var policeKills: Int
    public var traderKills: Int
    public var pirateKills: Int
    public var policeRecordScore: Int
    public var reputationScore: Int

    // MARK: Options (travel/combat defaults)
    public var autoFuel: Bool
    public var autoRepair: Bool
    public var clicks: Bool
    public var encounterType: Int
    public var raided: Bool

    // MARK: Quest flags
    public var monsterStatus: Int
    public var dragonflyStatus: Int
    public var japoriDiseaseStatus: Int
    public var moonBought: Bool
    public var monsterHull: Int

    // MARK: Identity + world
    public var nameCommander: String
    public var ship: Ship
    public var opponent: Ship
    /// Index 0 is the commander; 1..MAXCREWMEMBER are mercenaries.
    public var mercenary: [CrewMember]
    public var solarSystem: [SolarSystem]

    // MARK: Insurance / compliance
    public var escapePod: Bool
    public var insurance: Bool
    public var noClaim: Int
    public var inspected: Bool

    // MARK: UI auto-decisions
    public var alwaysIgnoreTraders: Bool
    public var alwaysIgnorePolice: Bool
    public var alwaysIgnorePirates: Bool
    public var alwaysIgnoreTradeInOrbit: Bool
    public var tribbleMessage: Bool
    public var alwaysInfo: Bool
    public var textualEncounters: Bool
    public var continuous: Bool
    public var attackFleeing: Bool

    // MARK: Wormholes
    public var wormhole: [Int]

    // MARK: Difficulty + versioning
    public var difficulty: Int
    public var versionMajor: Int
    public var versionMinor: Int

    // MARK: More flags
    public var artifactOnBoard: Bool
    public var reserveMoney: Bool
    public var priceDifferences: Bool
    public var aplScreen: Bool
    public var leaveEmpty: Int

    // MARK: Quest flags, round 2
    public var jarekStatus: Int
    public var invasionStatus: Int
    public var experimentAndWildStatus: Int
    public var fabricRipProbability: Int
    public var veryRareEncounter: Int
    public var reactorStatus: Int
    public var scarabStatus: Int
    public var trackedSystem: Int

    // MARK: Misc
    public var alreadyPaidForNewspaper: Bool
    public var gameLoaded: Bool
    public var shortcut1: Int
    public var shortcut2: Int
    public var shortcut3: Int
    public var shortcut4: Int
    public var litterWarning: Bool
    public var identifyStartup: Bool

    public init(
        credits: Int = 1_000,
        debt: Int = 0,
        days: Int = 0,
        warpSystem: Int = 0,
        selectedShipType: Int = 1,
        galacticChartSystem: Int = 0,
        curForm: Int = 0,
        buyPrice:   [Int] = Array(repeating: 0, count: GameLimits.maxTradeItem),
        sellPrice:  [Int] = Array(repeating: 0, count: GameLimits.maxTradeItem),
        buyingPrice:[Int] = Array(repeating: 0, count: GameLimits.maxTradeItem),
        shipPrice:  [Int] = Array(repeating: 0, count: GameLimits.maxShipType),
        policeKills: Int = 0,
        traderKills: Int = 0,
        pirateKills: Int = 0,
        policeRecordScore: Int = PoliceRecordScore.clean,
        reputationScore: Int = ReputationScore.harmless,
        autoFuel: Bool = false,
        autoRepair: Bool = false,
        clicks: Bool = false,
        encounterType: Int = 0,
        raided: Bool = false,
        monsterStatus: Int = 0,
        dragonflyStatus: Int = 0,
        japoriDiseaseStatus: Int = 0,
        moonBought: Bool = false,
        monsterHull: Int = 0,
        nameCommander: String = MercenaryNames.defaultCommanderName,
        ship: Ship = .starterGnat,
        opponent: Ship = Ship(type: 1),
        mercenary: [CrewMember] = SaveGame.defaultMercenaryRoster(),
        solarSystem: [SolarSystem] = SaveGame.defaultSolarSystems(),
        escapePod: Bool = false,
        insurance: Bool = false,
        noClaim: Int = 0,
        inspected: Bool = false,
        alwaysIgnoreTraders: Bool = false,
        alwaysIgnorePolice: Bool = false,
        alwaysIgnorePirates: Bool = false,
        alwaysIgnoreTradeInOrbit: Bool = false,
        tribbleMessage: Bool = false,
        alwaysInfo: Bool = false,
        textualEncounters: Bool = false,
        continuous: Bool = false,
        attackFleeing: Bool = false,
        wormhole: [Int] = Array(repeating: 0, count: GameLimits.maxWormhole),
        difficulty: Int = Difficulty.normal,
        versionMajor: Int = 1,
        versionMinor: Int = 2,
        artifactOnBoard: Bool = false,
        reserveMoney: Bool = false,
        priceDifferences: Bool = false,
        aplScreen: Bool = false,
        leaveEmpty: Int = 0,
        jarekStatus: Int = 0,
        invasionStatus: Int = 0,
        experimentAndWildStatus: Int = 0,
        fabricRipProbability: Int = EncounterOdds.fabricRipInitialProbability,
        veryRareEncounter: Int = 0,
        reactorStatus: Int = 0,
        scarabStatus: Int = 0,
        trackedSystem: Int = -1,
        alreadyPaidForNewspaper: Bool = false,
        gameLoaded: Bool = false,
        shortcut1: Int = 0,
        shortcut2: Int = 0,
        shortcut3: Int = 0,
        shortcut4: Int = 0,
        litterWarning: Bool = false,
        identifyStartup: Bool = false
    ) {
        self.credits = credits
        self.debt = debt
        self.days = days
        self.warpSystem = warpSystem
        self.selectedShipType = selectedShipType
        self.galacticChartSystem = galacticChartSystem
        self.curForm = curForm
        self.buyPrice = buyPrice
        self.sellPrice = sellPrice
        self.buyingPrice = buyingPrice
        self.shipPrice = shipPrice
        self.policeKills = policeKills
        self.traderKills = traderKills
        self.pirateKills = pirateKills
        self.policeRecordScore = policeRecordScore
        self.reputationScore = reputationScore
        self.autoFuel = autoFuel
        self.autoRepair = autoRepair
        self.clicks = clicks
        self.encounterType = encounterType
        self.raided = raided
        self.monsterStatus = monsterStatus
        self.dragonflyStatus = dragonflyStatus
        self.japoriDiseaseStatus = japoriDiseaseStatus
        self.moonBought = moonBought
        self.monsterHull = monsterHull
        self.nameCommander = nameCommander
        self.ship = ship
        self.opponent = opponent
        self.mercenary = mercenary
        self.solarSystem = solarSystem
        self.escapePod = escapePod
        self.insurance = insurance
        self.noClaim = noClaim
        self.inspected = inspected
        self.alwaysIgnoreTraders = alwaysIgnoreTraders
        self.alwaysIgnorePolice = alwaysIgnorePolice
        self.alwaysIgnorePirates = alwaysIgnorePirates
        self.alwaysIgnoreTradeInOrbit = alwaysIgnoreTradeInOrbit
        self.tribbleMessage = tribbleMessage
        self.alwaysInfo = alwaysInfo
        self.textualEncounters = textualEncounters
        self.continuous = continuous
        self.attackFleeing = attackFleeing
        self.wormhole = wormhole
        self.difficulty = difficulty
        self.versionMajor = versionMajor
        self.versionMinor = versionMinor
        self.artifactOnBoard = artifactOnBoard
        self.reserveMoney = reserveMoney
        self.priceDifferences = priceDifferences
        self.aplScreen = aplScreen
        self.leaveEmpty = leaveEmpty
        self.jarekStatus = jarekStatus
        self.invasionStatus = invasionStatus
        self.experimentAndWildStatus = experimentAndWildStatus
        self.fabricRipProbability = fabricRipProbability
        self.veryRareEncounter = veryRareEncounter
        self.reactorStatus = reactorStatus
        self.scarabStatus = scarabStatus
        self.trackedSystem = trackedSystem
        self.alreadyPaidForNewspaper = alreadyPaidForNewspaper
        self.gameLoaded = gameLoaded
        self.shortcut1 = shortcut1
        self.shortcut2 = shortcut2
        self.shortcut3 = shortcut3
        self.shortcut4 = shortcut4
        self.litterWarning = litterWarning
        self.identifyStartup = identifyStartup
    }

    /// Empty crew roster sized to match `Mercenary[MAXCREWMEMBER+1]` in
    /// the C code (indices 0..<32, slot 0 being the commander).
    public static func defaultMercenaryRoster() -> [CrewMember] {
        (0..<(GameLimits.maxCrewMember + 1)).map { idx in
            CrewMember(nameIndex: idx)
        }
    }

    /// Empty galaxy. Real galaxy generation happens in StartNewGame (a
    /// later phase); this lets new `SaveGame` instances be constructed
    /// for tests without touching the world generator yet.
    public static func defaultSolarSystems() -> [SolarSystem] {
        (0..<GameLimits.maxSolarSystem).map { idx in
            SolarSystem(nameIndex: idx)
        }
    }
}
