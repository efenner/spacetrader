// Derived from Space Trader by Pieter Spronck, GPLv2.
//
// Port of `MercenaryName[MAXCREWMEMBER]` from Src/Global.c:148-181. The
// commander occupies slot 0 — the C code stores the commander's editable
// name in `NameCommander`. In Swift, the commander name lives on
// `GameState` (Step 6), and this table holds only the defaults/literals:
// slot 0 is a placeholder ("Jameson", the default from Src/Global.c:146),
// slots 1..30 are the generic mercenary roster.

import Foundation

public enum MercenaryNames {
    public static let all: [String] = [
        "Jameson",    // slot 0 — commander (default; overridden by GameState at runtime)
        "Alyssa",
        "Armatur",
        "Bentos",
        "C2U2",
        "Chi'Ti",
        "Crystal",
        "Dane",
        "Deirdre",
        "Doc",
        "Draco",
        "Iranda",
        "Jeremiah",
        "Jujubal",
        "Krydon",
        "Luis",
        "Mercedez",
        "Milete",
        "Muri-L",
        "Mystyc",
        "Nandi",
        "Orestes",
        "Pancho",
        "PS37",
        "Quarck",
        "Sosumi",
        "Uma",
        "Wesley",
        "Wonton",
        "Yorvick",
        "Zeethibal",  // slot 30 — anagram for Elizabeth
    ]

    /// Default commander name baked into Src/Global.c:146; first entry the
    /// character-creation screen will show.
    public static let defaultCommanderName = "Jameson"
}
