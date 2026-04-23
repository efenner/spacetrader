// Derived from Space Trader by Pieter Spronck, GPLv2.
//
// Placeholder for Step 14 (`CmdrStatusEvent.c`). Lands in Step 13 as
// a stub so `ContentView` can reference the type; the full layout
// (credits, debt, skills, ship fittings) comes with Step 14.

import SwiftUI
import SpaceTraderCore

struct CommanderStatusView: View {
    @EnvironmentObject private var gs: GameState
    var body: some View {
        Text("Commander Status — coming in Step 14")
            .padding()
    }
}
