// Derived from Space Trader by Pieter Spronck, GPLv2.
//
// Helpers the hosting iOS app uses to stitch the SwiftUI tree to the
// persistence layer. Lives here (rather than in the hosting app)
// because the logic is entirely about types from `SpaceTraderCore`
// and reading them back through `SaveStore` — it's no more UI than
// the persistence tests are.

import Foundation
import SpaceTraderCore

public enum SpaceTraderBootstrap {

    /// Load the persisted save and user preferences from disk / user
    /// defaults; fall back to a fresh `GameState()` on first run or a
    /// decode failure. Callers typically wire the result into a
    /// SwiftUI `@StateObject` inside their `@main App`:
    ///
    ///     @StateObject private var gameState =
    ///         SpaceTraderBootstrap.makeInitialGameState()
    public static func makeInitialGameState() -> GameState {
        let gs: GameState
        if let loaded = try? SaveStore.default.load() {
            gs = GameState(save: loaded)
        } else {
            gs = GameState()
        }
        if let opts = OptionStore.load() {
            gs.options = opts
        }
        return gs
    }
}
