// Derived from Space Trader by Pieter Spronck, GPLv2.
//
// Human-readable label arrays from Src/Global.c: DifficultyLevel,
// SpecialResources, Status, Activity, SystemSize, TechLevel. Indexed by
// the matching integer constants in Constants.swift.

import Foundation

public enum DifficultyLabels {
    public static let all: [String] = [
        "Beginner", "Easy", "Normal", "Hard", "Impossible",
    ]
}

public enum ResourceLabels {
    public static let all: [String] = [
        "Nothing special",
        "Mineral rich",
        "Mineral poor",
        "Desert",
        "Sweetwater oceans",
        "Rich soil",
        "Poor soil",
        "Rich fauna",
        "Lifeless",
        "Weird mushrooms",
        "Special herbs",
        "Artistic populace",
        "Warlike populace",
    ]
}

public enum StatusLabels {
    public static let all: [String] = [
        "under no particular pressure",     // Uneventful
        "at war",                           // Ore and Weapons in demand
        "ravaged by a plague",              // Medicine in demand
        "suffering from a drought",         // Water in demand
        "suffering from extreme boredom",   // Games and Narcotics in demand
        "suffering from a cold spell",      // Furs in demand
        "suffering from a crop failure",    // Food in demand
        "lacking enough workers",           // Machinery and Robots in demand
    ]
}

public enum ActivityLabels {
    public static let all: [String] = [
        "Absent", "Minimal", "Few", "Some",
        "Moderate", "Many", "Abundant", "Swarms",
    ]
}

public enum SystemSizeLabels {
    public static let all: [String] = [
        "Tiny", "Small", "Medium", "Large", "Huge",
    ]
}

public enum TechLevelLabels {
    public static let all: [String] = [
        "Pre-agricultural",
        "Agricultural",
        "Medieval",
        "Renaissance",
        "Early Industrial",
        "Industrial",
        "Post-industrial",
        "Hi-tech",
    ]
}
