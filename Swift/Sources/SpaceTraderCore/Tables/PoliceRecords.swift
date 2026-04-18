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
