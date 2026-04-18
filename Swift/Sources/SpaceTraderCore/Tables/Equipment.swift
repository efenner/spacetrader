// Derived from Space Trader by Pieter Spronck, GPLv2.
//
// Port of the weapon/shield/gadget tables from Src/DataTypes.h:56-79 and
// Src/Global.c:207-235. Weapons and shields share an identical record
// layout (`name, power, price, techLevel, chance`); gadgets omit `power`.

import Foundation

public struct WeaponType: Sendable, Hashable {
    public let name: String
    public let power: Int
    public let price: Int
    public let techLevel: Int
    /// Percent chance this is fitted when a ship is being spawned.
    public let chance: Int
}

public struct ShieldType: Sendable, Hashable {
    public let name: String
    public let power: Int
    public let price: Int
    public let techLevel: Int
    public let chance: Int
}

public struct GadgetType: Sendable, Hashable {
    public let name: String
    public let price: Int
    public let techLevel: Int
    public let chance: Int
}

public enum Weapons {
    public static let all: [WeaponType] = [
        WeaponType(name: "Pulse laser",     power: WeaponIndex.pulsePower,    price:  2_000, techLevel: 5, chance: 50),
        WeaponType(name: "Beam laser",      power: WeaponIndex.beamPower,     price: 12_500, techLevel: 6, chance: 35),
        WeaponType(name: "Military laser",  power: WeaponIndex.militaryPower, price: 35_000, techLevel: 7, chance: 15),
        // Morgan's laser is not buyable.
        WeaponType(name: "Morgan's laser",  power: WeaponIndex.morganPower,   price: 50_000, techLevel: 8, chance:  0),
    ]
}

public enum Shields {
    public static let all: [ShieldType] = [
        ShieldType(name: "Energy shield",     power: ShieldIndex.energyPower,     price:  5_000, techLevel: 5, chance: 70),
        ShieldType(name: "Reflective shield", power: ShieldIndex.reflectivePower, price: 20_000, techLevel: 6, chance: 30),
        // Lightning shield is not buyable.
        ShieldType(name: "Lightning shield",  power: ShieldIndex.lightningPower,  price: 45_000, techLevel: 8, chance:  0),
    ]
}

public enum Gadgets {
    public static let all: [GadgetType] = [
        GadgetType(name: "5 extra cargo bays", price:   2_500, techLevel: 4, chance: 35),
        GadgetType(name: "Auto-repair system", price:   7_500, techLevel: 5, chance: 20),
        GadgetType(name: "Navigating system",  price:  15_000, techLevel: 6, chance: 20),
        GadgetType(name: "Targeting system",   price:  25_000, techLevel: 6, chance: 20),
        GadgetType(name: "Cloaking device",    price: 100_000, techLevel: 7, chance:  5),
        // Fuel compactor is not buyable.
        GadgetType(name: "Fuel compactor",     price:  30_000, techLevel: 8, chance:  0),
    ]
}
