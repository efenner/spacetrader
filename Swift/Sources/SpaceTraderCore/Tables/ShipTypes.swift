// Derived from Space Trader by Pieter Spronck, GPLv2.
//
// Port of `SHIPTYPE` + the `Shiptype[MAXSHIPTYPE+EXTRASHIPS]` table from
// Src/DataTypes.h:92-111 and Src/Global.c:186-204.
//
// Indices 0..<10 are the player-buyable ships; 10..<15 are encounter-only
// ships (Space monster, Dragonfly, Mantis, Scarab, Bottle).

import Foundation

public struct ShipType: Sendable, Hashable {
    public let name: String
    public let cargoBays: Int
    public let weaponSlots: Int
    public let shieldSlots: Int
    public let gadgetSlots: Int
    public let crewQuarters: Int
    /// Each tank is 10 parsecs of range.
    public let fuelTanks: Int
    public let minTechLevel: Int
    /// Cost to fill one fuel tank.
    public let costOfFuel: Int
    /// Base ship cost in credits.
    public let price: Int
    public let bounty: Int
    /// Percentage of ships encountered that are this type (sums to 100).
    public let occurrence: Int
    public let hullStrength: Int
    /// Encountered as police with at least this level of police strength.
    public let police: Int
    public let pirates: Int
    public let traders: Int
    /// Repair cost per hull point.
    public let repairCosts: Int
    /// Visual size class; influences hit chance in combat.
    public let size: Int
}

public enum ShipTypes {
    public static let all: [ShipType] = [
        ShipType(name: "Flea",        cargoBays: 10, weaponSlots: 0, shieldSlots: 0, gadgetSlots: 0, crewQuarters: 1, fuelTanks: GameLimits.maxRange, minTechLevel: 4, costOfFuel:   1, price:   2_000, bounty:   5, occurrence:  2, hullStrength:  25, police: -1, pirates: -1, traders: 0, repairCosts: 1, size: 0),
        ShipType(name: "Gnat",        cargoBays: 15, weaponSlots: 1, shieldSlots: 0, gadgetSlots: 1, crewQuarters: 1, fuelTanks: 14, minTechLevel: 5, costOfFuel:   2, price:  10_000, bounty:  50, occurrence: 28, hullStrength: 100, police:  0, pirates:  0, traders: 0, repairCosts: 1, size: 1),
        ShipType(name: "Firefly",     cargoBays: 20, weaponSlots: 1, shieldSlots: 1, gadgetSlots: 1, crewQuarters: 1, fuelTanks: 17, minTechLevel: 5, costOfFuel:   3, price:  25_000, bounty:  75, occurrence: 20, hullStrength: 100, police:  0, pirates:  0, traders: 0, repairCosts: 1, size: 1),
        ShipType(name: "Mosquito",    cargoBays: 15, weaponSlots: 2, shieldSlots: 1, gadgetSlots: 1, crewQuarters: 1, fuelTanks: 13, minTechLevel: 5, costOfFuel:   5, price:  30_000, bounty: 100, occurrence: 20, hullStrength: 100, police:  0, pirates:  1, traders: 0, repairCosts: 1, size: 1),
        ShipType(name: "Bumblebee",   cargoBays: 25, weaponSlots: 1, shieldSlots: 2, gadgetSlots: 2, crewQuarters: 2, fuelTanks: 15, minTechLevel: 5, costOfFuel:   7, price:  60_000, bounty: 125, occurrence: 15, hullStrength: 100, police:  1, pirates:  1, traders: 0, repairCosts: 1, size: 2),
        ShipType(name: "Beetle",      cargoBays: 50, weaponSlots: 0, shieldSlots: 1, gadgetSlots: 1, crewQuarters: 3, fuelTanks: 14, minTechLevel: 5, costOfFuel:  10, price:  80_000, bounty:  50, occurrence:  3, hullStrength:  50, police: -1, pirates: -1, traders: 0, repairCosts: 1, size: 2),
        ShipType(name: "Hornet",      cargoBays: 20, weaponSlots: 3, shieldSlots: 2, gadgetSlots: 1, crewQuarters: 2, fuelTanks: 16, minTechLevel: 6, costOfFuel:  15, price: 100_000, bounty: 200, occurrence:  6, hullStrength: 150, police:  2, pirates:  3, traders: 1, repairCosts: 2, size: 3),
        ShipType(name: "Grasshopper", cargoBays: 30, weaponSlots: 2, shieldSlots: 2, gadgetSlots: 3, crewQuarters: 3, fuelTanks: 15, minTechLevel: 6, costOfFuel:  15, price: 150_000, bounty: 300, occurrence:  2, hullStrength: 150, police:  3, pirates:  4, traders: 2, repairCosts: 3, size: 3),
        ShipType(name: "Termite",     cargoBays: 60, weaponSlots: 1, shieldSlots: 3, gadgetSlots: 2, crewQuarters: 3, fuelTanks: 13, minTechLevel: 7, costOfFuel:  20, price: 225_000, bounty: 300, occurrence:  2, hullStrength: 200, police:  4, pirates:  5, traders: 3, repairCosts: 4, size: 4),
        ShipType(name: "Wasp",        cargoBays: 35, weaponSlots: 3, shieldSlots: 2, gadgetSlots: 2, crewQuarters: 3, fuelTanks: 14, minTechLevel: 7, costOfFuel:  20, price: 300_000, bounty: 500, occurrence:  2, hullStrength: 200, police:  5, pirates:  6, traders: 4, repairCosts: 5, size: 4),
        // Non-buyable beyond this point.
        ShipType(name: "Space monster", cargoBays:  0, weaponSlots: 3, shieldSlots: 0, gadgetSlots: 0, crewQuarters: 1, fuelTanks:  1, minTechLevel: 8, costOfFuel:  1, price: 500_000, bounty:   0, occurrence: 0, hullStrength: 500, police: 8, pirates: 8, traders: 8, repairCosts: 1, size: 4),
        ShipType(name: "Dragonfly",    cargoBays:  0, weaponSlots: 2, shieldSlots: 3, gadgetSlots: 2, crewQuarters: 1, fuelTanks:  1, minTechLevel: 8, costOfFuel:  1, price: 500_000, bounty:   0, occurrence: 0, hullStrength:  10, police: 8, pirates: 8, traders: 8, repairCosts: 1, size: 1),
        ShipType(name: "Mantis",       cargoBays:  0, weaponSlots: 3, shieldSlots: 1, gadgetSlots: 3, crewQuarters: 3, fuelTanks:  1, minTechLevel: 8, costOfFuel:  1, price: 500_000, bounty:   0, occurrence: 0, hullStrength: 300, police: 8, pirates: 8, traders: 8, repairCosts: 1, size: 2),
        ShipType(name: "Scarab",       cargoBays: 20, weaponSlots: 2, shieldSlots: 0, gadgetSlots: 0, crewQuarters: 2, fuelTanks:  1, minTechLevel: 8, costOfFuel:  1, price: 500_000, bounty:   0, occurrence: 0, hullStrength: 400, police: 8, pirates: 8, traders: 8, repairCosts: 1, size: 3),
        ShipType(name: "Bottle",       cargoBays:  0, weaponSlots: 0, shieldSlots: 0, gadgetSlots: 0, crewQuarters: 0, fuelTanks:  1, minTechLevel: 8, costOfFuel:  1, price:     100, bounty:   0, occurrence: 0, hullStrength:  10, police: 8, pirates: 8, traders: 8, repairCosts: 1, size: 1),
    ]
}
