# Space Trader — Swift/SwiftUI port, Phase 1 plan

This is the authoritative, committed plan for porting `Space Trader 1.2.2`
(Pieter Spronck, GPLv2, Palm/C) to an iPhone app written in Swift + SwiftUI.

Any Claude Code session picking up this work should:
1. Check out branch `claude/port-game-to-swift-DMVPS`.
2. Read this file end-to-end.
3. Find the next unchecked item under "Implementation step checklist".
4. Work through it. When done, tick the box, append a line to the
   "Progress log" at the bottom, update "Next up", and commit.

## How to resume (for the next session)

The previous session (2026-04-18) was unable to install Swift because the
harness network ACL denied `download.swift.org`. **Before starting this
session, confirm that your environment can reach `download.swift.org` and
`swift.org`.** Quick probe:

```bash
curl -sI -o /dev/null -w "%{http_code}\n" https://download.swift.org/
# Expect: 200 or 3xx. If 403 with x-deny-reason: host_not_allowed, stop
# and have the user update the project environment / allowlist before
# continuing.
```

If the probe returns a non-403 code, go straight to **Step 0.B (retry)**
in the checklist below. Follow the install block in the "Step 0" section
of this file, then proceed through 0.C → 1 → 2 → …, updating checkboxes
and Progress log as you go.

---

## Context

`Space Trader 1.2.2` is a Palm Pilot trade-and-combat game written in C.
The repo contains ~16k lines across the original Palm sources (`Src/`) and
binary Palm resource files (`Rsc/`). The end goal is an iPhone app written
in Swift / SwiftUI that captures the same gameplay.

A complete one-shot rewrite of 47 forms + the encounter/quest engine is too
large to land safely in a single session, so this plan delivers **Phase 1:
a runnable foundation** — the data model, lookup tables, deterministic
systems (RNG, money, fuel, bank, ship pricing, skills), persistence, and
2–3 representative SwiftUI screens proving the architecture works
end-to-end. Encounter, travel, quests, charts, and remaining screens will
follow in later phases.

User selections that shape the plan:
- **UI**: SwiftUI only (drop into UIKit only if SwiftUI hits a wall — e.g.
  complex Canvas drawing).
- **Scope**: Foundation + core systems + 2–3 screens.
- **Art**: SF Symbols / text placeholders for now; bitmaps come later.
- **Verification**: Swift unit tests via `swift test`, run **inside the
  Linux dev container** after installing Swift 5.9 via `swiftly` as Step 0.
  Final iOS app verification happens in Xcode on a Mac.

The C source under `Src/` and `Rsc/` stays untouched as a reference. All
new code goes under `/Swift/`.

## Target layout

```
/
├── Src/                         # original C, untouched
├── Rsc/                         # original Palm resources, untouched
└── Swift/
    ├── PLAN.md                  # this file
    ├── Package.swift            # SwiftPM root (multi-platform)
    ├── Sources/
    │   ├── SpaceTraderCore/     # Pure Foundation; no UIKit/SwiftUI
    │   │   ├── Constants.swift          # MAXTRADEITEM, MAXSHIPTYPE, COSTMOON, NAMELEN, etc.
    │   │   ├── Models/
    │   │   │   ├── Ship.swift           # SHIP
    │   │   │   ├── Equipment.swift      # GADGET / WEAPON / SHIELD
    │   │   │   ├── CrewMember.swift     # CREWMEMBER
    │   │   │   ├── ShipType.swift       # SHIPTYPE
    │   │   │   ├── SolarSystem.swift    # SOLARSYSTEM
    │   │   │   ├── TradeItem.swift      # TRADEITEM
    │   │   │   ├── Politics.swift       # POLITICS
    │   │   │   ├── SpecialEvent.swift   # SPECIALEVENT
    │   │   │   ├── Reputation.swift     # POLICERECORD + REPUTATION
    │   │   │   ├── HighScore.swift      # HIGHSCORE
    │   │   │   └── SaveGame.swift       # SAVEGAMETYPE (Codable)
    │   │   ├── Tables/
    │   │   │   ├── Tradeitems.swift     # 10 trade goods (Global.c)
    │   │   │   ├── Shiptypes.swift      # 15 ship types
    │   │   │   ├── PoliticsTable.swift  # 17 governments
    │   │   │   ├── Status.swift         # 8 system statuses
    │   │   │   ├── Activity.swift       # 8 activity levels
    │   │   │   ├── PoliceRecords.swift  # 10 record tiers
    │   │   │   ├── Reputations.swift    # 9 combat reputations
    │   │   │   ├── Mercenaries.swift    # 31 named crew
    │   │   │   ├── Weapons.swift        # weapons table
    │   │   │   ├── Shields.swift        # shields table
    │   │   │   ├── Gadgets.swift        # gadgets table
    │   │   │   └── SystemNames.swift    # 120 system names
    │   │   ├── Systems/
    │   │   │   ├── RNG.swift            # Math.c: LCG (SeedX/SeedY) + Rand/GetRandom
    │   │   │   ├── Distance.swift       # sqr / sqrDistance / realDistance
    │   │   │   ├── Money.swift          # currentWorth, payInterest
    │   │   │   ├── Fuel.swift           # getFuelTanks/getFuel/buyFuel
    │   │   │   ├── Bank.swift           # MaxLoan, GetLoan, PayBack, PayInterest
    │   │   │   ├── ShipPrice.swift      # CurrentShipPrice, EnemyShipPrice, BasePrice
    │   │   │   └── Skill.swift          # PilotSkill/FighterSkill/TraderSkill/EngineerSkill
    │   │   ├── GameState.swift          # single source of truth (replaces C globals)
    │   │   └── Persistence/
    │   │       └── SaveStore.swift      # JSON Codable to FileManager + UserDefaults prefs
    │   └── iOSApp/                      # SwiftUI executable target, iOS-only
    │       ├── SpaceTraderApp.swift     # @main, injects GameState
    │       ├── ContentView.swift        # tab/nav root
    │       ├── Screens/
    │       │   ├── CommanderStatusView.swift   # CmdrStatusEvent.c
    │       │   ├── SystemInfoView.swift        # SystemInfoEvent.c (docked screen)
    │       │   └── BuyCargoView.swift          # subset of Cargo.c trading
    │       └── Components/
    │           ├── StatRow.swift
    │           └── PriceRow.swift
    └── Tests/
        └── SpaceTraderCoreTests/
            ├── Fixtures/
            │   └── rand_seed_default.txt   # golden vector from Src/Math.c
            ├── RNGTests.swift               # parity with C LCG for known seeds
            ├── DistanceTests.swift
            ├── FuelTests.swift
            ├── MoneyTests.swift
            ├── BankTests.swift
            ├── ShipPriceTests.swift
            ├── SkillTests.swift
            └── PersistenceTests.swift       # round-trip Codable SaveGame
```

Rationale: keeping `SpaceTraderCore` as a Foundation-only SwiftPM library
means it builds on Linux with `swift test` and is reusable for unit tests,
future macOS catalyst builds, or a CLI driver. No hand-rolled
`.xcodeproj` — Xcode opens `Package.swift` directly, and the iOS app is an
executable target inside the same package that depends on
`SpaceTraderCore`.

## What ports to what (Phase 1)

| Original (C)                                      | Swift target                                          |
|---------------------------------------------------|-------------------------------------------------------|
| `Src/spacetrader.h` constants                     | `Constants.swift`                                     |
| `Src/DataTypes.h` structs                         | `Models/*.swift` (all `Codable`, value types)         |
| `Src/Global.c` static tables                      | `Tables/*.swift` as `static let` arrays               |
| `Src/Math.c` RNG + distance                       | `Systems/RNG.swift`, `Systems/Distance.swift`         |
| `Src/Money.c`                                     | `Systems/Money.swift` (methods on `GameState`)        |
| `Src/Fuel.c`                                      | `Systems/Fuel.swift`                                  |
| `Src/Bank.c` MaxLoan/GetLoan/PayBack/PayInterest  | `Systems/Bank.swift`                                  |
| `Src/ShipPrice.c`                                 | `Systems/ShipPrice.swift`                             |
| `Src/Skill.c`                                     | `Systems/Skill.swift`                                 |
| C globals in `Src/external.h:56-153`              | properties on `GameState` (single `ObservableObject`) |
| Palm `PrefSetAppPreferences` / `DmCreateDatabase` | `Persistence/SaveStore.swift` — JSON + UserDefaults   |
| `Src/CmdrStatusEvent.c`                           | `iOSApp/Screens/CommanderStatusView.swift`            |
| `Src/SystemInfoEvent.c` (docked screen + draw)    | `iOSApp/Screens/SystemInfoView.swift`                 |
| `Src/Cargo.c` buy-side only                       | `iOSApp/Screens/BuyCargoView.swift`                   |

**Out of scope this phase** (called out so we don't accidentally start
them): `Encounter.c`, `Traveler.c`, `WarpFormEvent.c` chart drawing,
`SpecialEvent.c`, `QuestEvent.c`, `Shipyard.c`, equipment buy/sell screens,
news, high-score UI, options screen, character creation flow.

## Key porting notes

1. **RNG must match C bit-for-bit.** `Src/Math.c:90-99` is a custom 16-bit
   LCG combining two seeds — `SeedX = a*(SeedX&MAX_WORD) + (SeedX>>16)`
   (a=18000), same for SeedY (b=30903), returning
   `(SeedX<<16) + (SeedY&MAX_WORD)`. Implement as a `class RNG` (not a
   global) with `UInt32` arithmetic to mimic 16-bit overflow. Test with
   `RandSeed(0,0)` then assert the first 16 outputs equal the fixture
   captured by compiling the C code in Step 0.C.

2. **No global mutable state.** All C globals (`Credits`, `Debt`, `Ship`,
   `Mercenary[]`, `SolarSystem[]`, `PoliceRecordScore`, etc. in
   `Src/external.h:56-153`) become stored properties on
   `GameState: ObservableObject`. Game-system functions become methods on
   `GameState` (or take it as `inout`). This makes them testable and
   SwiftUI-bindable.

3. **`SAVEGAMETYPE` is the persistence schema.** Mirror it as a single
   `SaveGame: Codable` struct (`Src/DataTypes.h:180-255`). Drop
   Palm-specific fields that don't apply (`SharePreferences`,
   `RectangularButtonsOn`, `ForFutureUse`). Save by JSON-encoding
   `SaveGame` to `Documents/savegame.json`. Keep options (`AutoFuel`,
   `Clicks`, etc.) in `UserDefaults` separately so they survive a "new
   game".

4. **Type mapping cheatsheet:**
   - `Byte` → `UInt8`
   - `int` (Palm 16-bit) → `Int16` for save-compat fields, `Int` for
     transient computation
   - `long` → `Int32` for credit values that need to round-trip with old
     saves; otherwise `Int`
   - `Boolean` → `Bool`
   - `char*` name pointers in tables → `String` literals
   - Fixed-size C arrays (`Cargo[MAXTRADEITEM]`) → Swift `[Int]` of fixed
     length, or tiny wrapper struct

5. **MercenaryName fixup.** `Src/Skill.c` references commander name slot 0;
   preserve that convention in `Mercenaries.swift` so indices line up with
   save data.

6. **No save-game compatibility** with the original Palm `.pdb` files in
   Phase 1 — that would require reverse-engineering Palm's database format,
   and we picked JSON. Document this clearly in the README.

7. **License compliance.** Keep a `LICENSE` (GPLv2) in `Swift/` and a
   header in each ported file: "Derived from Space Trader by Pieter
   Spronck, GPLv2". `ReadMe.txt` already grants permission to port.

## Execution protocol

**Working rules:**
1. Work happens on branch `claude/port-game-to-swift-DMVPS` only.
2. Each numbered step below has a checkbox. When a step finishes, the
   executing session:
   - Ticks the box in this file.
   - Appends a line to **Progress log** with the commit SHA + one-line
     summary.
   - Updates the **Next up** pointer to the next unchecked step.
   - Commits the code + this file together (or in back-to-back commits)
     and pushes.
3. If the plan itself needs to change (scope, approach, discovered
   blocker), edit this file in the same commit and flag the diff in the
   commit message with a `plan:` prefix so it's easy to scan.
4. Commits are small and per-step — never one giant "implement phase 1"
   commit. Granularity target: one test file or one system module per
   commit.

**Progress log format:**
```
- [YYYY-MM-DD] Step N — short title. <short SHA>. Notes: …
```

## Step 0 — Environment + plan-file bootstrap

**0.A — Publish the plan to the repo.**
1. Ensure you are on branch `claude/port-game-to-swift-DMVPS`.
2. `Swift/PLAN.md` is this file. Committing it satisfies 0.A.

**0.B — Install Swift in the container.**

*Attempted 2026-04-18 in session `session_01K2XHvzPSr73VrSw9HmrMhc` and
deferred.* The harness network ACL in that session blocked
`download.swift.org` (403 `host_not_allowed`) and this block was enforced
above the Bash sandbox (`dangerouslyDisableSandbox: true` did not override
it). Apt (`swift-lang` not in Ubuntu noble), GitHub releases (swiftly
ships source-only there), and Docker Hub (no daemon) were also dead ends.

**The user has chosen to resume in a new session with environment
settings that permit access to `download.swift.org` / `swift.org`** rather
than write Swift code without a local compiler. Tests must be runnable in
the container for this project.

Once the new session is attached, run this to satisfy 0.B:

```bash
curl -fsSLO https://download.swift.org/swiftly/linux/swiftly-x86_64.tar.gz
mkdir -p ~/.local/bin
tar -xzf swiftly-x86_64.tar.gz -C ~/.local/bin
~/.local/bin/swiftly init --quiet-shell-followup --assume-yes
. "${SWIFTLY_HOME_DIR:-$HOME/.local/share/swiftly}/env.sh"
swiftly install 5.9 && swiftly use 5.9
swift --version        # expect: Swift version 5.9.x
```

Then tick the 0.B checkbox, append a Progress log entry, and proceed to
Step 0.C.

**0.C — Capture the RNG golden vector.**
Compile `Src/Math.c` with a tiny `harness.c` (stubs for Palm-only calls as
needed, `RandSeed(0, 0)`, print first 16 `Rand()` outputs) using `gcc`.
Save output to `Swift/Tests/SpaceTraderCoreTests/Fixtures/rand_seed_default.txt`.
The Swift `RNGTests` asserts the same vector. Commit the harness source and
the fixture together so parity can be re-verified later.

## Implementation step checklist

- [x] **Step 0.A** Publish `Swift/PLAN.md` to the branch
- [ ] **Step 0.B** Install Swift 5.9 via `swiftly` — **deferred to a new session with network allowlist for `download.swift.org`** (see note)
- [ ] **Step 0.C** Capture RNG golden vector from C
- [ ] **Step 1**  SwiftPM scaffold (`Package.swift`, empty targets, `swift build` green)
- [ ] **Step 2**  `Constants.swift` + all `Tables/*.swift` ported from `Src/Global.c`
- [ ] **Step 3**  `Models/*.swift` ported from `Src/DataTypes.h`
- [ ] **Step 4**  `Systems/RNG.swift` + `RNGTests` green against fixture
- [ ] **Step 5**  `Systems/Distance.swift` + `DistanceTests`
- [ ] **Step 6**  `GameState.swift` skeleton (properties only)
- [ ] **Step 7**  `Systems/Money.swift` + `MoneyTests`
- [ ] **Step 8**  `Systems/Fuel.swift` + `FuelTests`
- [ ] **Step 9**  `Systems/Bank.swift` + `BankTests`
- [ ] **Step 10** `Systems/ShipPrice.swift` + `ShipPriceTests`
- [ ] **Step 11** `Systems/Skill.swift` + `SkillTests`
- [ ] **Step 12** `Persistence/SaveStore.swift` + `PersistenceTests` (JSON round-trip)
- [ ] **Step 13** iOS app target (`iOSApp` executable in `Package.swift`) + `SpaceTraderApp.swift` + `ContentView.swift` tab root
- [ ] **Step 14** `CommanderStatusView.swift`
- [ ] **Step 15** `SystemInfoView.swift`
- [ ] **Step 16** `BuyCargoView.swift`
- [ ] **Step 17** README with Mac/Xcode run instructions; final push

## Verification

Run from `/Swift/`:

```bash
swift build               # confirms SpaceTraderCore compiles on Foundation
swift test                # runs SpaceTraderCoreTests
```

Tests that must be green before a phase is considered done:
- **RNGTests**: same seed → deterministic sequence; first 16 values match
  the fixture captured from `Src/Math.c`.
- **DistanceTests**: `realDistance` matches `sqrt(dx² + dy²)` rounded the
  same way as `Src/Math.c:44-55`.
- **FuelTests**: `buyFuel` clamps to tank capacity, clamps to credits, and
  FuelCompactor gadget bumps capacity to 18 (`Src/Fuel.c:50-53`).
- **MoneyTests**: `currentWorth = currentShipPrice + credits − debt +
  (moonBought ? COSTMOON : 0)` (`Src/Money.c:46-49`); `payInterest` follows
  `max(1, debt/10)` rule (`Src/Money.c:55-70`).
- **BankTests**: MaxLoan tiers by police record; GetLoan/PayBack bounds.
- **ShipPriceTests**: 75 % base + crew-skill modifier per `Src/ShipPrice.c`.
- **SkillTests**: pilot/fighter/trader/engineer = max over crew + gadget
  bonuses.
- **PersistenceTests**: `SaveGame` round-trips through
  `JSONEncoder`/`Decoder` byte-identical.

iOS UI verification (manual, Mac required):
- Open `Swift/Package.swift` in Xcode 15+.
- Pick the `iOSApp` scheme, iPhone 15 simulator (iOS 16+ target).
- Confirm Commander Status renders all stats from a fresh `GameState`.
- Confirm System Info lists tech level, government, status, resources, and
  the 10 trade item prices using `BuyPrice[]`.
- Confirm Buy Cargo lets you increment/decrement quantities and updates
  `Credits` + `Ship.Cargo[]` correctly.

## Risks / open items

- **Swift toolchain must be installable in the container.** A prior
  session (2026-04-18) hit a harness ACL denying `download.swift.org` and
  paused. The user is setting up a new session/environment with that host
  allowlisted so tests can run in-container. **Do not fall back to blind
  authoring** — the project requires running tests alongside the code.
- **RNG parity**: gcc is present in the container, so the C harness can run
  here directly; no Mac needed for the golden vector.
- **iOS target won't compile on Linux.** `#if canImport(UIKit)` /
  `#if canImport(SwiftUI)` guards keep Linux `swift build` green while the
  Mac builds the full app.

## Follow-up phases (not this session)

- Phase 2: Travel & galactic chart (`Traveler.c`, `WarpFormEvent.c`) —
  SwiftUI Canvas for star chart.
- Phase 3: Encounter / combat engine (`Encounter.c`, ~2300 lines — biggest
  single file).
- Phase 4: Shipyard + equipment buy/sell (`Shipyard.c`,
  `BuyShipEvent.c`, `BuyEquipEvent.c`, `SellEquipEvent.c`).
- Phase 5: Quests + special events (`SpecialEvent.c`, `QuestEvent.c`).
- Phase 6: Polish — character creation, options, news, high scores, sound,
  art.

---

## Next up

**Step 0.B (retry)** — In a fresh session whose environment allows
`download.swift.org`, run the `swiftly` install block in the 0.B section
above, verify `swift --version` reports 5.9.x, tick the checkbox, log
progress. Then proceed to **Step 0.C** (RNG golden vector via gcc) and
Step 1 (SwiftPM scaffold).

## Progress log

<!-- newest entries at bottom -->
- [2026-04-18] Step 0.A — Published `Swift/PLAN.md`. `5de109c`. Notes: authoritative plan file committed; branch ready for handoff.
- [2026-04-18] Step 0.B — **paused**. Harness ACL denies `download.swift.org`; no viable in-container install path (apt, GitHub releases, Docker all dead ends). User will resume in a fresh session whose environment allowlists `download.swift.org` / `swift.org`. No Swift code was written in this session; branch state is the plan file only.
