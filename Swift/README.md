# Space Trader — SwiftUI port (Phase 1)

A Swift / SwiftUI port of Pieter Spronck's
[Space Trader 1.2.2](http://www.spronck.net/picoverse/spacetrader), the
Palm Pilot trade-and-combat game. This tree is a **Phase-1 foundation**:
the data model, lookup tables, deterministic gameplay systems (RNG,
distance, money, fuel, bank, ship pricing, skills, cargo buy/sell),
JSON persistence, and three iPhone screens proving the architecture
works end-to-end. Encounter / travel / quest / chart systems and the
remaining screens come in later phases.

The authoritative roadmap — what's done, what's deferred, the
rationale for each choice — lives in
[`PLAN.md`](PLAN.md). Start there when resuming work.

## Repository layout

```
Swift/
├── Package.swift                   # SwiftPM manifest; iOSApp target lives here too
├── PLAN.md                         # Phase-1 plan and progress log
├── README.md                       # this file
├── Sources/
│   ├── SpaceTraderCore/            # Foundation-only library (builds on Linux too)
│   │   ├── Constants.swift
│   │   ├── GameState.swift         # replaces the ~100 C globals
│   │   ├── Models/                 # Ship, CrewMember, SolarSystem, SaveGame, …
│   │   ├── Tables/                 # TradeItems, ShipTypes, Politics, …
│   │   ├── Systems/                # RNG, Distance, Money, Fuel, Bank, ShipPrice, Skill, Cargo
│   │   └── Persistence/            # SaveStore (JSON) + GameOptions (UserDefaults)
│   └── iOSApp/                     # SwiftUI executable (macOS-host-only; see below)
│       ├── SpaceTraderApp.swift
│       ├── ContentView.swift
│       ├── Screens/                # CommanderStatusView, SystemInfoView, BuyCargoView
│       └── Components/             # StatRow, PriceRow
└── Tests/
    └── SpaceTraderCoreTests/       # XCTest; 125 cases covering the deterministic core
        └── Fixtures/
            ├── rand_harness.c                # C harness mirroring Src/Math.c
            └── rand_seed_default.txt         # RNG golden vector captured from C
```

## Building and running

### Linux (or any host without Xcode) — core tests only

`SpaceTraderCore` is Foundation-only, so the core library and its
XCTest suite run anywhere a Swift toolchain is installed. The 2026-04
sessions used Swift 6.0.3 on Ubuntu 24.04 (downloaded directly from
`download.swift.org`; see PLAN.md's Step 0.B block if you need the
exact install commands). The package declares
`swift-tools-version:5.9`, which 6.0.3 accepts.

```bash
cd Swift
swift build
swift test          # expect: 125 tests, 0 failures
```

The `iOSApp` target is wrapped in `#if os(macOS)` inside
`Package.swift`, so on Linux its target list evaluates empty — no
SwiftUI / UIKit dependency leaks onto the Linux build.

### macOS / Xcode — full iPhone app

Requires Xcode 15 or newer.

1. Open `Swift/Package.swift` directly in Xcode (File → Open…).
2. Pick the **iOSApp** scheme at the top of the window.
3. Choose an iPhone simulator (iOS 16 or newer).
4. Run (⌘R).

You should see:
- **Status** tab — commander name in the nav bar; sections for Skills
  (base / adapted), Standing (kills, police record, reputation,
  difficulty), Finances (days, credits, debt, net worth).
- **System** tab — the current system's tech level, government, size,
  resources, status, police & pirate activity, plus the ten trade-item
  buy prices (rendered as `—` when the system doesn't sell an item).
- **Trade** tab — buy / sell one unit at a time. Disabled buttons
  mean one of the four refusal guards from `Cargo.c:862-884` has
  fired (too much debt, no stock, no free bays, can't afford one).

`SaveGame` persists to `Documents/savegame.json`; the options subset
(auto-fuel, auto-repair, ignore-X flags, etc.) lives in `UserDefaults`
under `com.spacetrader.options` so it survives a "New Game".

### Regenerating the RNG golden vector

The Palm LCG is bit-reproducible; the Swift port tests against a
vector captured from the original C. The harness is checked in, so
any C compiler can re-verify:

```bash
cd Tests/SpaceTraderCoreTests/Fixtures
gcc -std=c99 -O0 -Wall -o rand_harness rand_harness.c
./rand_harness > rand_seed_default.txt
```

## License

Space Trader is © Pieter Spronck, released under the GNU General
Public License v2. This port inherits that license — see the
`Derived from Space Trader by Pieter Spronck, GPLv2.` header atop
every ported source file. Original `Src/` and `Rsc/` trees at the
repository root are untouched and remain the canonical reference.

The author's original `ReadMe.txt` at the repository root grants
permission to port Space Trader to another platform. Per its
request, this port acknowledges the origin in every file and in
this README.
