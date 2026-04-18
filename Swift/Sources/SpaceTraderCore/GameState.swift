// Derived from Space Trader by Pieter Spronck, GPLv2.
//
// Single source of truth for the runtime game. Replaces the ~100 C
// global variables enumerated in Src/external.h:56-153 with one
// observable container. The persistable subset lives inside the
// `save: SaveGame` property; transient UI-only fields (cheat counter,
// current form, etc.) sit alongside.
//
// SwiftUI bindings use `@ObservedObject` / `@EnvironmentObject` once
// the iOS target lands (Step 13). On Linux the ObservableObject
// conformance is skipped via a Combine-availability guard, so the same
// class compiles everywhere `SpaceTraderCore` is built.

import Foundation

#if canImport(Combine)
import Combine

public final class GameState: ObservableObject {
    @Published public var save: SaveGame

    public init(save: SaveGame = SaveGame()) {
        self.save = save
    }
}
#else
// Linux / non-Combine platforms — still usable from tests and CLI.
public final class GameState {
    public var save: SaveGame

    public init(save: SaveGame = SaveGame()) {
        self.save = save
    }
}
#endif

public extension GameState {
    /// Discard the current game and seed a fresh default. Equivalent to
    /// `StartNewGame` zeroing the C globals before it runs the world
    /// generator. Called at "New Game" time by the UI.
    func reset() {
        self.save = SaveGame()
    }

    // MARK: Convenience accessors that forward to `save`
    //
    // Mirror the most common C globals so call sites read naturally.
    // Kept as thin forwards — no calculation — so the persisted schema
    // remains the single source of truth.

    var credits: Int {
        get { save.credits }
        set { save.credits = newValue }
    }

    var debt: Int {
        get { save.debt }
        set { save.debt = newValue }
    }

    var days: Int {
        get { save.days }
        set { save.days = newValue }
    }

    var ship: Ship {
        get { save.ship }
        set { save.ship = newValue }
    }

    /// Commander crew member — slot 0 in the roster, equivalent to the
    /// C `COMMANDER` macro.
    var commander: CrewMember {
        get { save.mercenary[0] }
        set { save.mercenary[0] = newValue }
    }

    /// Solar system the commander is currently docked at (C
    /// `CURSYSTEM`).
    var currentSystem: SolarSystem {
        get { save.solarSystem[commander.curSystem] }
        set { save.solarSystem[commander.curSystem] = newValue }
    }

    var moonBought: Bool {
        get { save.moonBought }
        set { save.moonBought = newValue }
    }
}
