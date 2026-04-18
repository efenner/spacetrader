// Derived from Space Trader by Pieter Spronck, GPLv2.
//
// SpaceTraderCore — Foundation-only port of the Space Trader 1.2.2 game
// engine. See Swift/PLAN.md for the porting plan and the mapping from
// original C symbols to Swift types. No UIKit/SwiftUI imports belong
// here; only pure data + deterministic game systems.

import Foundation

public enum SpaceTraderCore {
    /// Version tag for the Swift port. Bumped when the save-file
    /// schema changes in an incompatible way.
    public static let portVersion = "0.1.0-phase1"
}
