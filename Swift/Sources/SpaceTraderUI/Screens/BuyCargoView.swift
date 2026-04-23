// Derived from Space Trader by Pieter Spronck, GPLv2.
//
// Buy-side subset of `Src/Cargo.c`. Each of the ten trade items gets
// a row showing its unit price, the docked system's stock, and the
// quantity in the hold; +1 / -1 buttons drive `gs.buyCargo` and
// `gs.sellCargo`. Refusal paths (no stock, not affordable, no free
// bays, SellPrice==0) surface as disabled buttons — the full alert
// choreography from Cargo.c:866-885 is deferred to a later UX pass.

import SwiftUI
import SpaceTraderCore

public struct BuyCargoView: View {
    @EnvironmentObject private var gs: GameState

    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                Section {
                    StatRow(label: "Credits", value: "\(gs.credits) cr.")
                    StatRow(label: "Cargo bays",
                            value: "\(gs.filledCargoBays()) / \(gs.totalCargoBays())")
                }
                Section("Trade") {
                    ForEach(0..<GameLimits.maxTradeItem, id: \.self) { i in
                        PriceRow(
                            name: TradeItems.all[i].name,
                            unitPrice: gs.save.buyPrice[i],
                            marketQty: gs.currentSystem.qty[i],
                            holdQty: gs.save.ship.cargo[i],
                            canBuy: canBuy(index: i),
                            canSell: canSell(index: i),
                            onBuy:  { gs.buyCargo(index: i, amount: 1) },
                            onSell: { gs.sellCargo(index: i, amount: 1) }
                        )
                    }
                }
            }
            .navigationTitle("Trade")
        }
    }

    private func canBuy(index: Int) -> Bool {
        gs.save.debt <= Money.debtTooLarge
            && gs.save.buyPrice[index] > 0
            && gs.currentSystem.qty[index] > 0
            && gs.filledCargoBays() < gs.totalCargoBays()
            && gs.credits >= gs.save.buyPrice[index]
    }

    private func canSell(index: Int) -> Bool {
        gs.save.ship.cargo[index] > 0 && gs.save.sellPrice[index] > 0
    }
}

#Preview {
    let gs = GameState()
    gs.save.mercenary[0].curSystem = 0
    gs.save.ship.crew[0] = 0
    gs.save.solarSystem[0].qty[TradeItemIndex.water] = 12
    gs.save.buyPrice[TradeItemIndex.water] = 32
    gs.save.sellPrice[TradeItemIndex.water] = 28
    return BuyCargoView().environmentObject(gs)
}
