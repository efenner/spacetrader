// Derived from Space Trader by Pieter Spronck, GPLv2.
//
// Port of `SPECIALEVENT` from Src/DataTypes.h:160-166. The full
// 37-entry `SpecialEvent[]` table in Src/Global.c:491-591 references
// Palm resource string IDs and isn't migrated wholesale here — quest
// text will be rebuilt alongside the quest engine in Phase 5. For now
// the struct shape is enough to land the Codable `SaveGame`.

import Foundation

public struct SpecialEvent: Codable, Sendable, Hashable {
    public var title: String
    /// Opaque string-resource identifier on Palm. Carried through for
    /// save-file parity; will be replaced by a Swift enum in Phase 5.
    public var questStringID: Int
    public var price: Int
    public var occurrence: Int
    /// Events that are pure news flashes (no quest branch) set this
    /// to true so the engine skips quest-tracking bookkeeping.
    public var justAMessage: Bool

    public init(
        title: String,
        questStringID: Int,
        price: Int,
        occurrence: Int,
        justAMessage: Bool
    ) {
        self.title = title
        self.questStringID = questStringID
        self.price = price
        self.occurrence = occurrence
        self.justAMessage = justAMessage
    }
}
