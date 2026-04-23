// Derived from Space Trader by Pieter Spronck, GPLv2.
//
// Ports of the POLICERECORD and REPUTATION name-score tables from
// Src/Global.c:48-74.

import Foundation

public struct PoliceRecord: Sendable, Hashable {
    public let name: String
    public let minScore: Int
}

public struct ReputationTier: Sendable, Hashable {
    public let name: String
    public let minScore: Int
}

public enum PoliceRecords {
    public static let all: [PoliceRecord] = [
        PoliceRecord(name: "Psycho",   minScore: -100),
        PoliceRecord(name: "Villain",  minScore: PoliceRecordScore.psychopath),
        PoliceRecord(name: "Criminal", minScore: PoliceRecordScore.villain),
        PoliceRecord(name: "Crook",    minScore: PoliceRecordScore.criminal),
        PoliceRecord(name: "Dubious",  minScore: PoliceRecordScore.dubious),
        PoliceRecord(name: "Clean",    minScore: PoliceRecordScore.clean),
        PoliceRecord(name: "Lawful",   minScore: PoliceRecordScore.lawful),
        PoliceRecord(name: "Trusted",  minScore: PoliceRecordScore.trusted),
        PoliceRecord(name: "Liked",    minScore: PoliceRecordScore.helper),
        PoliceRecord(name: "Hero",     minScore: PoliceRecordScore.hero),
    ]
}

public enum Reputations {
    public static let all: [ReputationTier] = [
        ReputationTier(name: "Harmless",        minScore: ReputationScore.harmless),
        ReputationTier(name: "Mostly harmless", minScore: ReputationScore.mostlyHarmless),
        ReputationTier(name: "Poor",            minScore: ReputationScore.poor),
        ReputationTier(name: "Average",         minScore: ReputationScore.average),
        ReputationTier(name: "Above average",   minScore: ReputationScore.aboveAverage),
        ReputationTier(name: "Competent",       minScore: ReputationScore.competent),
        ReputationTier(name: "Dangerous",       minScore: ReputationScore.dangerous),
        ReputationTier(name: "Deadly",          minScore: ReputationScore.deadly),
        ReputationTier(name: "Elite",           minScore: ReputationScore.elite),
    ]
}

public extension PoliceRecords {
    /// Name of the tier the commander currently sits in. Mirrors the
    /// while-loop walk in `CmdrStatusEvent.c:77-82`: find the highest
    /// tier whose `minScore` doesn't exceed `score`, with a defensive
    /// floor at the first tier for very-negative scores.
    static func tier(for score: Int) -> PoliceRecord {
        var i = 0
        while i < all.count && score >= all[i].minScore { i += 1 }
        i -= 1
        if i < 0 { i = 0 }
        return all[i]
    }
}

public extension Reputations {
    /// Reputation tier name. Same walk pattern as `PoliceRecords.tier`.
    static func tier(for score: Int) -> ReputationTier {
        var i = 0
        while i < all.count && score >= all[i].minScore { i += 1 }
        i -= 1
        if i < 0 { i = 0 }
        return all[i]
    }
}
