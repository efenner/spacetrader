// Derived from Space Trader by Pieter Spronck, GPLv2.
//
// Placeholder for Step 16 — the buy-side subset of `Cargo.c`. Step 16
// wires this up with per-item increment / decrement buttons that drive
// `Credits` and `Ship.Cargo[]`.

import SwiftUI
import SpaceTraderCore

struct BuyCargoView: View {
    @EnvironmentObject private var gs: GameState
    var body: some View {
        Text("Buy Cargo — coming in Step 16")
            .padding()
    }
}
