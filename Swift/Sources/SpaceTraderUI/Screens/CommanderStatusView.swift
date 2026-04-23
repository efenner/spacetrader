// Derived from Space Trader by Pieter Spronck, GPLv2.
//
// Port of the Commander Status form drawn in `Src/CmdrStatusEvent.c`.
// The Palm version uses hand-positioned labels on a single form; on
// iOS we lay it out as a sectioned `Form` so it scrolls naturally on
// smaller devices and follows platform conventions.
//
// Skills show "base [adapted]" — the raw crew max on the left, the
// difficulty + gadget + quest-adjusted value in brackets, matching
// the `DisplaySkill` helper in CmdrStatusEvent.c:43-51.

import SwiftUI
import SpaceTraderCore

public struct CommanderStatusView: View {
    @EnvironmentObject private var gs: GameState

    public init() {}

    public var body: some View {
        NavigationStack {
            Form {
                Section("Skills") {
                    skillRow("Pilot",    base: gs.commander.pilot,    adapted: gs.pilotSkill())
                    skillRow("Fighter",  base: gs.commander.fighter,  adapted: gs.fighterSkill())
                    skillRow("Trader",   base: gs.commander.trader,   adapted: gs.traderSkill())
                    skillRow("Engineer", base: gs.commander.engineer, adapted: gs.engineerSkill())
                }

                Section("Standing") {
                    StatRow(label: "Total kills",
                            value: "\(gs.save.policeKills + gs.save.traderKills + gs.save.pirateKills)")
                    StatRow(label: "Police record",
                            value: PoliceRecords.tier(for: gs.save.policeRecordScore).name)
                    StatRow(label: "Reputation",
                            value: Reputations.tier(for: gs.save.reputationScore).name)
                    StatRow(label: "Difficulty",
                            value: DifficultyLabels.all[gs.save.difficulty])
                }

                Section("Finances") {
                    StatRow(label: "Days", value: "\(gs.save.days)")
                    StatRow(label: "Credits", value: "\(gs.credits) cr.")
                    StatRow(label: "Debt", value: "\(gs.save.debt) cr.")
                    StatRow(label: "Net worth", value: "\(gs.currentWorth()) cr.")
                }
            }
            .navigationTitle(gs.save.nameCommander)
        }
    }

    private func skillRow(_ name: String, base: Int, adapted: Int) -> some View {
        StatRow(label: name, value: "\(base) [\(adapted)]")
    }
}

#Preview {
    let gs = GameState()
    gs.save.nameCommander = "Jameson"
    gs.save.mercenary[0].pilot = 5
    gs.save.mercenary[0].fighter = 3
    gs.save.mercenary[0].trader = 7
    gs.save.mercenary[0].engineer = 4
    gs.save.ship.crew[0] = 0
    return CommanderStatusView().environmentObject(gs)
}
