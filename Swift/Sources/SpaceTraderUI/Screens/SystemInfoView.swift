// Derived from Space Trader by Pieter Spronck, GPLv2.
//
// Port of the System Information form in `Src/SystemInfoEvent.c`.
// Phase-1 shows the read-only half of the screen: the current
// system's name, tech level, government, status, resources, size,
// and police/pirate activity (SystemInfoEvent.c:253-323), plus the
// ten trade-item buy prices pulled from `gs.save.buyPrice[]`.
//
// The C screen also exposes buttons for Special Events, the
// Personnel Roster, and the Newspaper; those belong to flows this
// phase doesn't cover.

import SwiftUI
import SpaceTraderCore

public struct SystemInfoView: View {
    @EnvironmentObject private var gs: GameState

    public init() {}

    public var body: some View {
        NavigationStack {
            Form {
                Section("Overview") {
                    let system = gs.currentSystem
                    let politics = PoliticsTable.all[system.politics]

                    StatRow(label: "Tech level",
                            value: TechLevelLabels.all[system.techLevel])
                    StatRow(label: "Government", value: politics.name)
                    StatRow(label: "Size", value: SystemSizeLabels.all[system.size])
                    StatRow(label: "Resources",
                            value: ResourceLabels.all[system.specialResources])
                    StatRow(label: "Status",
                            value: StatusLabels.all[system.status])
                    StatRow(label: "Police",
                            value: ActivityLabels.all[politics.strengthPolice])
                    StatRow(label: "Pirates",
                            value: ActivityLabels.all[politics.strengthPirates])
                }

                Section("Market") {
                    ForEach(0..<GameLimits.maxTradeItem, id: \.self) { i in
                        StatRow(label: TradeItems.all[i].name,
                                value: priceText(gs.save.buyPrice[i]))
                    }
                }
            }
            .navigationTitle(SystemNames.all[gs.currentSystem.nameIndex])
        }
    }

    /// `BuyPrice[i] == 0` means "not sold here" per the C pricing
    /// logic in `Src/Skill.c:142-164`. Render that explicitly instead
    /// of showing "0 cr." which would look like a free giveaway.
    private func priceText(_ price: Int) -> String {
        price > 0 ? "\(price) cr." : "—"
    }
}

#Preview {
    let gs = GameState()
    // Seed a plausibly-populated current system for the preview.
    gs.save.mercenary[0] = CrewMember(nameIndex: 0, curSystem: 0)
    gs.save.ship.crew[0] = 0
    gs.save.solarSystem[0] = SolarSystem(
        nameIndex: 0,
        techLevel: 6,
        politics: 1,             // Capitalist State
        status: SystemStatusIndex.uneventful,
        specialResources: Resource.none,
        size: 2
    )
    gs.save.buyPrice[TradeItemIndex.water] = 32
    gs.save.buyPrice[TradeItemIndex.ore] = 680
    return SystemInfoView().environmentObject(gs)
}
