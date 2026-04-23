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
├── Package.swift                   # SwiftPM manifest — two library products
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
│   └── SpaceTraderUI/              # SwiftUI library (macOS/iOS only; see below)
│       ├── Bootstrap.swift         # makeInitialGameState() helper
│       ├── ContentView.swift       # TabView root
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

The `SpaceTraderUI` target is wrapped in `#if os(macOS)` inside
`Package.swift`, so on Linux its target list evaluates empty — no
SwiftUI / UIKit dependency leaks onto the Linux build.

### macOS — running the core tests from the CLI

```bash
cd Swift
swift test
```

Requires `xcode-select -p` to point at Xcode.app (not Command Line
Tools) so `XCTest` resolves; fix with
`sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`
if needed. You can also press ⌘U in Xcode with the
`SpaceTraderCore` scheme selected — same 125 tests, prettier UI.

### macOS — running the iPhone app

SwiftPM doesn't produce a proper iOS `.app` bundle (no `Info.plist`
with `CFBundleIdentifier`, no bundle structure), so we ship
`SpaceTraderUI` as a **library** and leave a thin Xcode iOS App
project as the hosting shell. One-time setup:

1. Open Xcode. **File → New → Project → iOS → App.**
   - Product Name: `SpaceTrader`
   - Interface: `SwiftUI`
   - Language: `Swift`
   - Storage: None
   - Save inside the repo root (e.g. `/Users/you/spacetrader/SpaceTraderApp/`).
     This is *outside* the `Swift/` SwiftPM package directory.

2. With the new project open: **File → Add Package Dependencies…**
   → click **Add Local…** → pick the `Swift/` folder (not the root).
   In the following dialog, link **both** products (`SpaceTraderCore`
   and `SpaceTraderUI`) to your app target.

3. Replace the generated `ContentView.swift` file content with:
   ```swift
   import SwiftUI
   import SpaceTraderCore
   import SpaceTraderUI

   struct RootView: View {
       @StateObject private var gameState =
           SpaceTraderBootstrap.makeInitialGameState()

       var body: some View {
           ContentView().environmentObject(gameState)
       }
   }
   ```
   (You can delete the renaming wrapper and inline `RootView` into
   the `App` struct if you prefer; keeping it separate makes the
   `@StateObject` lifecycle explicit.)

4. Open the generated `SpaceTraderApp.swift` and change its `body`:
   ```swift
   WindowGroup { RootView() }
   ```

5. Build & run. Pick any iOS 16+ iPhone simulator. ⌘R.

You should see a three-tab SwiftUI app:
- **Status** — commander name in the nav bar; sections for Skills
  (base / adapted), Standing (kills, police record, reputation,
  difficulty), Finances (days, credits, debt, net worth).
- **System** — the current system's tech level, government, size,
  resources, status, police & pirate activity, plus the ten trade-item
  buy prices (rendered as `—` when the system doesn't sell an item).
- **Trade** — buy / sell one unit at a time. Disabled buttons mean
  one of the four refusal guards from `Cargo.c:862-884` has fired
  (too much debt, no stock, no free bays, can't afford one).

`SaveGame` persists to `Documents/savegame.json`; the options
subset (auto-fuel, auto-repair, ignore-X flags, etc.) lives in
`UserDefaults` under `com.spacetrader.options` so it survives a
"New Game". Persistence load runs at app launch inside
`SpaceTraderBootstrap.makeInitialGameState()`; wiring `save()` to
actual game events (end-of-day, after a trade, `scenePhase ==
.background`, …) is deliberately deferred — that's a Phase-2 call.

### Regenerating the RNG golden vector

The Palm LCG is bit-reproducible; the Swift port tests against a
vector captured from the original C. The harness is checked in, so
any C compiler can re-verify:

```bash
cd Tests/SpaceTraderCoreTests/Fixtures
clang -std=c99 -O0 -Wall -o rand_harness rand_harness.c
diff <(./rand_harness) rand_seed_default.txt     # empty = parity
rm rand_harness                                   # binary is gitignored
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
