// Derived from Space Trader by Pieter Spronck, GPLv2.
//
// Port of `SOLARSYSTEM` from Src/DataTypes.h:114-127. The galaxy is a
// fixed-length array of 120 of these; `nameIndex` points back into
// `SystemNames.all`, which is in 1:1 correspondence.

import Foundation

public struct SolarSystem: Codable, Sendable, Hashable {
    public var nameIndex: Int
    public var techLevel: Int
    public var politics: Int
    public var status: Int
    /// Galaxy-grid X (0..<GALAXYWIDTH = 150).
    public var x: Int
    /// Galaxy-grid Y (0..<GALAXYHEIGHT = 110).
    public var y: Int
    public var specialResources: Int
    public var size: Int
    /// On-market quantity of each of the 10 trade items. Changes
    /// slowly day-to-day — see `DoPrices()` / the trade-item reset
    /// logic in the C code.
    public var qty: [Int]
    /// Days remaining before `qty` is reshuffled.
    public var countDown: Int
    public var visited: Bool
    /// Active special-event index (`MOONFORSALE`, `JAPORIDISEASE`, …)
    /// or `-1` when no event is attached.
    public var special: Int

    public init(
        nameIndex: Int,
        techLevel: Int = 0,
        politics: Int = 0,
        status: Int = SystemStatusIndex.uneventful,
        x: Int = 0,
        y: Int = 0,
        specialResources: Int = Resource.none,
        size: Int = 0,
        qty: [Int] = Array(repeating: 0, count: GameLimits.maxTradeItem),
        countDown: Int = 0,
        visited: Bool = false,
        special: Int = -1
    ) {
        self.nameIndex = nameIndex
        self.techLevel = techLevel
        self.politics = politics
        self.status = status
        self.x = x
        self.y = y
        self.specialResources = specialResources
        self.size = size
        self.qty = qty
        self.countDown = countDown
        self.visited = visited
        self.special = special
    }
}
