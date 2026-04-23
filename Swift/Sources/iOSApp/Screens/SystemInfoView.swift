// Derived from Space Trader by Pieter Spronck, GPLv2.
//
// Placeholder for Step 15 (`SystemInfoEvent.c`). The full docked-
// screen layout — tech level, government, status, resources, and the
// ten trade-item prices from `BuyPrice[]` — comes with Step 15.

import SwiftUI
import SpaceTraderCore

struct SystemInfoView: View {
    @EnvironmentObject private var gs: GameState
    var body: some View {
        Text("System Info — coming in Step 15")
            .padding()
    }
}
