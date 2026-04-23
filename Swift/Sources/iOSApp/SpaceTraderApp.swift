// Derived from Space Trader by Pieter Spronck, GPLv2.
//
// App entry point. On launch we try to load an existing save from
// `Documents/savegame.json`; on first run or a decode failure we seed
// a fresh `GameState`. The state object is injected as a
// `@StateObject` here so it stays alive for the lifetime of the app,
// and exposed to the tree via `EnvironmentObject`.

import SwiftUI
import SpaceTraderCore

@main
struct SpaceTraderApp: App {
    @StateObject private var gameState: GameState = SpaceTraderApp.makeInitialState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameState)
        }
    }

    private static func makeInitialState() -> GameState {
        let store = SaveStore.default
        if let loaded = try? store.load() {
            let gs = GameState(save: loaded)
            if let opts = OptionStore.load() {
                gs.options = opts
            }
            return gs
        }
        return GameState()
    }
}
