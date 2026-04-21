// Derived from Space Trader by Pieter Spronck, GPLv2.
//
// `GameOptions` mirrors the subset of C globals that are genuine
// *preferences* rather than game-state: auto-fuel, auto-repair, the
// ignore-X-encounter toggles, UI niceties, etc. They originate in
// `Src/external.h:116-145` and are read/written all over the
// Options-screen form handlers.
//
// Unlike the full `SaveGame`, options are meant to outlive a "New
// Game", so they round-trip through `UserDefaults` instead of the
// save file. The bridge functions on `GameState` let us splice them
// out of an active SaveGame and back in.

import Foundation

public struct GameOptions: Codable, Sendable, Hashable {
    public var autoFuel: Bool
    public var autoRepair: Bool
    public var clicks: Bool
    public var alwaysIgnoreTraders: Bool
    public var alwaysIgnorePolice: Bool
    public var alwaysIgnorePirates: Bool
    public var alwaysIgnoreTradeInOrbit: Bool
    public var alwaysInfo: Bool
    public var textualEncounters: Bool
    public var continuous: Bool
    public var reserveMoney: Bool
    public var priceDifferences: Bool
    public var litterWarning: Bool
    public var identifyStartup: Bool

    public init(
        autoFuel: Bool = false,
        autoRepair: Bool = false,
        clicks: Bool = false,
        alwaysIgnoreTraders: Bool = false,
        alwaysIgnorePolice: Bool = false,
        alwaysIgnorePirates: Bool = false,
        alwaysIgnoreTradeInOrbit: Bool = false,
        alwaysInfo: Bool = false,
        textualEncounters: Bool = false,
        continuous: Bool = false,
        reserveMoney: Bool = false,
        priceDifferences: Bool = false,
        litterWarning: Bool = false,
        identifyStartup: Bool = false
    ) {
        self.autoFuel = autoFuel
        self.autoRepair = autoRepair
        self.clicks = clicks
        self.alwaysIgnoreTraders = alwaysIgnoreTraders
        self.alwaysIgnorePolice = alwaysIgnorePolice
        self.alwaysIgnorePirates = alwaysIgnorePirates
        self.alwaysIgnoreTradeInOrbit = alwaysIgnoreTradeInOrbit
        self.alwaysInfo = alwaysInfo
        self.textualEncounters = textualEncounters
        self.continuous = continuous
        self.reserveMoney = reserveMoney
        self.priceDifferences = priceDifferences
        self.litterWarning = litterWarning
        self.identifyStartup = identifyStartup
    }
}

public extension GameOptions {
    /// Snapshot the option-flavored fields of a SaveGame.
    init(save: SaveGame) {
        self.init(
            autoFuel: save.autoFuel,
            autoRepair: save.autoRepair,
            clicks: save.clicks,
            alwaysIgnoreTraders: save.alwaysIgnoreTraders,
            alwaysIgnorePolice: save.alwaysIgnorePolice,
            alwaysIgnorePirates: save.alwaysIgnorePirates,
            alwaysIgnoreTradeInOrbit: save.alwaysIgnoreTradeInOrbit,
            alwaysInfo: save.alwaysInfo,
            textualEncounters: save.textualEncounters,
            continuous: save.continuous,
            reserveMoney: save.reserveMoney,
            priceDifferences: save.priceDifferences,
            litterWarning: save.litterWarning,
            identifyStartup: save.identifyStartup
        )
    }

    /// Write these options back onto a SaveGame.
    func apply(to save: inout SaveGame) {
        save.autoFuel = autoFuel
        save.autoRepair = autoRepair
        save.clicks = clicks
        save.alwaysIgnoreTraders = alwaysIgnoreTraders
        save.alwaysIgnorePolice = alwaysIgnorePolice
        save.alwaysIgnorePirates = alwaysIgnorePirates
        save.alwaysIgnoreTradeInOrbit = alwaysIgnoreTradeInOrbit
        save.alwaysInfo = alwaysInfo
        save.textualEncounters = textualEncounters
        save.continuous = continuous
        save.reserveMoney = reserveMoney
        save.priceDifferences = priceDifferences
        save.litterWarning = litterWarning
        save.identifyStartup = identifyStartup
    }
}

/// `UserDefaults`-backed storage for `GameOptions`. `standardKey` is
/// namespaced so it's easy to share one `UserDefaults` domain with
/// other iOS app prefs without collisions.
public enum OptionStore {

    public static let standardKey = "com.spacetrader.options"

    /// Decode options from the given defaults. Missing / malformed
    /// entries return nil; callers treat that as "use defaults".
    public static func load(
        key: String = standardKey,
        defaults: UserDefaults = .standard
    ) -> GameOptions? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(GameOptions.self, from: data)
    }

    public static func save(
        _ options: GameOptions,
        key: String = standardKey,
        defaults: UserDefaults = .standard
    ) throws {
        let data = try JSONEncoder().encode(options)
        defaults.set(data, forKey: key)
    }

    public static func clear(
        key: String = standardKey,
        defaults: UserDefaults = .standard
    ) {
        defaults.removeObject(forKey: key)
    }
}

public extension GameState {
    /// The option-flavored subset of the current SaveGame.
    var options: GameOptions {
        get { GameOptions(save: save) }
        set { newValue.apply(to: &save) }
    }

    /// Start a fresh game **preserving** user preferences. Mirrors
    /// the plan's "options survive a New Game" rule from Step 12 —
    /// in-memory the preserved struct is re-applied; cross-launch
    /// persistence happens via `OptionStore`.
    func resetPreservingOptions() {
        let opts = options
        self.save = SaveGame()
        opts.apply(to: &save)
    }
}
