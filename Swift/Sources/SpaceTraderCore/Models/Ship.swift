// Derived from Space Trader by Pieter Spronck, GPLv2.
//
// Port of `SHIP` from Src/DataTypes.h:41-53. This is the runtime state
// of any ship the engine tracks — the player's ship, the current
// opponent, and the set of fixed encounter ships (Dragonfly, Scarab,
// Space monster).
//
// Fixed-size arrays in the C code become Swift `[Int]` with the
// convention that `-1` means "empty slot" for weapons/shields/gadgets
// and "vacant" for crew, matching the C sentinels.

import Foundation

public struct Ship: Codable, Sendable, Hashable {
    /// Index into `ShipTypes.all`. Values >= `MAXSHIPTYPE` select
    /// encounter-only types (Space monster, Dragonfly, Mantis, Scarab,
    /// Bottle) in the order they appear in the table.
    public var type: Int
    /// Units held of each of the 10 trade items.
    public var cargo: [Int]
    /// Weapon slot occupants; -1 = empty. Size must be `MAXWEAPON` (3).
    public var weapon: [Int]
    /// Shield slot occupants; -1 = empty. Size must be `MAXSHIELD` (3).
    public var shield: [Int]
    /// Current strength of each equipped shield. Ship.ShieldStrength
    /// in the C code; Byte-wide per slot.
    public var shieldStrength: [Int]
    /// Gadget slot occupants; -1 = empty.
    public var gadget: [Int]
    /// Crew slot occupants; each is an index into Mercenary[]; -1 = vacant.
    public var crew: [Int]
    /// Fuel tanks remaining (each tank = 10 parsecs).
    public var fuel: Int
    public var hull: Int
    public var tribbles: Int

    public init(
        type: Int,
        cargo: [Int] = Array(repeating: 0, count: GameLimits.maxTradeItem),
        weapon: [Int] = Array(repeating: -1, count: GameLimits.maxWeapon),
        shield: [Int] = Array(repeating: -1, count: GameLimits.maxShield),
        shieldStrength: [Int] = Array(repeating: 0, count: GameLimits.maxShield),
        gadget: [Int] = Array(repeating: -1, count: GameLimits.maxGadget),
        crew: [Int] = Array(repeating: -1, count: GameLimits.maxCrew),
        fuel: Int = 0,
        hull: Int = 0,
        tribbles: Int = 0
    ) {
        self.type = type
        self.cargo = cargo
        self.weapon = weapon
        self.shield = shield
        self.shieldStrength = shieldStrength
        self.gadget = gadget
        self.crew = crew
        self.fuel = fuel
        self.hull = hull
        self.tribbles = tribbles
    }
}

public extension Ship {
    /// Default Gnat starter ship, mirroring the `Ship` initializer in
    /// Src/Global.c:239-251 before StartNewGame adjusts it.
    static var starterGnat: Ship {
        var s = Ship(type: 1)
        s.weapon[0] = WeaponIndex.pulseLaser
        s.crew[0]   = 0           // commander
        s.fuel      = 14          // full tank
        s.hull      = 100         // full hull for Gnat
        return s
    }
}
