// Derived from Space Trader by Pieter Spronck, GPLv2.
//
// Port of `HIGHSCORE` from Src/DataTypes.h:258-265. The C table is
// fixed-size (MAXHIGHSCORE = 3); we keep the shape but let callers
// store it in a plain `[HighScore]`.

import Foundation

public struct HighScore: Codable, Sendable, Hashable {
    public var name: String
    /// 0 = Killed, 1 = Retired, 2 = Bought moon. See `Highscore`
    /// constants (Src/spacetrader.h:432-434).
    public var status: Int
    public var days: Int
    public var worth: Int
    public var difficulty: Int

    public init(
        name: String,
        status: Int,
        days: Int,
        worth: Int,
        difficulty: Int
    ) {
        self.name = name
        self.status = status
        self.days = days
        self.worth = worth
        self.difficulty = difficulty
    }
}
