// Derived from Space Trader by Pieter Spronck, GPLv2.
//
// Tab root. Three tabs for Phase 1 — Commander Status, System Info,
// and Buy Cargo — matching the subset of Palm forms called out in
// PLAN.md. Travel, combat, the galactic chart, and the shipyard are
// later phases.

import SwiftUI
import SpaceTraderCore

struct ContentView: View {
    var body: some View {
        TabView {
            CommanderStatusView()
                .tabItem { Label("Status", systemImage: "person.crop.circle") }

            SystemInfoView()
                .tabItem { Label("System", systemImage: "globe") }

            BuyCargoView()
                .tabItem { Label("Trade", systemImage: "shippingbox") }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(GameState())
}
