// Derived from Space Trader by Pieter Spronck, GPLv2.
//
// Port of `CREWMEMBER` from Src/DataTypes.h:82-89. A crew member is
// identified by its index in the global `Mercenary[]` table; slot 0 is
// always the commander (see `COMMANDER` macro in
// Src/spacetrader.h:448).

import Foundation

public struct CrewMember: Codable, Sendable, Hashable {
    /// Index into `MercenaryNames.all`. Slot 0 = commander.
    public var nameIndex: Int
    public var pilot: Int
    public var fighter: Int
    public var trader: Int
    public var engineer: Int
    /// Current solar-system index. For the commander this is the
    /// "where I am" pointer; for hireable mercs it's "where I can be
    /// found".
    public var curSystem: Int

    public init(
        nameIndex: Int,
        pilot: Int = 0,
        fighter: Int = 0,
        trader: Int = 0,
        engineer: Int = 0,
        curSystem: Int = 0
    ) {
        self.nameIndex = nameIndex
        self.pilot = pilot
        self.fighter = fighter
        self.trader = trader
        self.engineer = engineer
        self.curSystem = curSystem
    }
}
