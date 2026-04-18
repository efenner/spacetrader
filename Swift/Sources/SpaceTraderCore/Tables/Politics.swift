// Derived from Space Trader by Pieter Spronck, GPLv2.
//
// Port of `POLITICS` + the `Politics[MAXPOLITICS]` table from
// Src/DataTypes.h:146-158 and Src/Global.c:335-354.

import Foundation

public struct Politics: Sendable, Hashable {
    public let name: String
    /// Reaction level to illegal goods: 0 = total acceptance.
    public let reactionIllegal: Int
    /// Police strength: 0 = no police.
    public let strengthPolice: Int
    /// Pirate strength: 0 = no pirates.
    public let strengthPirates: Int
    /// Trader strength: 0 = no traders.
    public let strengthTraders: Int
    public let minTechLevel: Int
    public let maxTechLevel: Int
    /// How easily officials can be bribed; 0 = unbribeable.
    public let bribeLevel: Int
    public let drugsOK: Bool
    public let firearmsOK: Bool
    /// Trade item index especially wanted here; -1 = none.
    public let wanted: Int
}

public enum PoliticsTable {
    public static let all: [Politics] = [
        Politics(name: "Anarchy",          reactionIllegal: 0, strengthPolice: 0, strengthPirates: 7, strengthTraders: 1, minTechLevel: 0, maxTechLevel: 5, bribeLevel: 7, drugsOK: true,  firearmsOK: true,  wanted: TradeItemIndex.food),
        Politics(name: "Capitalist State", reactionIllegal: 2, strengthPolice: 3, strengthPirates: 2, strengthTraders: 7, minTechLevel: 4, maxTechLevel: 7, bribeLevel: 1, drugsOK: true,  firearmsOK: true,  wanted: TradeItemIndex.ore),
        Politics(name: "Communist State",  reactionIllegal: 6, strengthPolice: 6, strengthPirates: 4, strengthTraders: 4, minTechLevel: 1, maxTechLevel: 5, bribeLevel: 5, drugsOK: true,  firearmsOK: true,  wanted: -1),
        Politics(name: "Confederacy",      reactionIllegal: 5, strengthPolice: 4, strengthPirates: 3, strengthTraders: 5, minTechLevel: 1, maxTechLevel: 6, bribeLevel: 3, drugsOK: true,  firearmsOK: true,  wanted: TradeItemIndex.games),
        Politics(name: "Corporate State",  reactionIllegal: 2, strengthPolice: 6, strengthPirates: 2, strengthTraders: 7, minTechLevel: 4, maxTechLevel: 7, bribeLevel: 2, drugsOK: true,  firearmsOK: true,  wanted: TradeItemIndex.robots),
        Politics(name: "Cybernetic State", reactionIllegal: 0, strengthPolice: 7, strengthPirates: 7, strengthTraders: 5, minTechLevel: 6, maxTechLevel: 7, bribeLevel: 0, drugsOK: false, firearmsOK: false, wanted: TradeItemIndex.ore),
        Politics(name: "Democracy",        reactionIllegal: 4, strengthPolice: 3, strengthPirates: 2, strengthTraders: 5, minTechLevel: 3, maxTechLevel: 7, bribeLevel: 2, drugsOK: true,  firearmsOK: true,  wanted: TradeItemIndex.games),
        Politics(name: "Dictatorship",     reactionIllegal: 3, strengthPolice: 4, strengthPirates: 5, strengthTraders: 3, minTechLevel: 0, maxTechLevel: 7, bribeLevel: 2, drugsOK: true,  firearmsOK: true,  wanted: -1),
        Politics(name: "Fascist State",    reactionIllegal: 7, strengthPolice: 7, strengthPirates: 7, strengthTraders: 1, minTechLevel: 4, maxTechLevel: 7, bribeLevel: 0, drugsOK: false, firearmsOK: true,  wanted: TradeItemIndex.machinery),
        Politics(name: "Feudal State",     reactionIllegal: 1, strengthPolice: 1, strengthPirates: 6, strengthTraders: 2, minTechLevel: 0, maxTechLevel: 3, bribeLevel: 6, drugsOK: true,  firearmsOK: true,  wanted: TradeItemIndex.firearms),
        Politics(name: "Military State",   reactionIllegal: 7, strengthPolice: 7, strengthPirates: 0, strengthTraders: 6, minTechLevel: 2, maxTechLevel: 7, bribeLevel: 0, drugsOK: false, firearmsOK: true,  wanted: TradeItemIndex.robots),
        Politics(name: "Monarchy",         reactionIllegal: 3, strengthPolice: 4, strengthPirates: 3, strengthTraders: 4, minTechLevel: 0, maxTechLevel: 5, bribeLevel: 4, drugsOK: true,  firearmsOK: true,  wanted: TradeItemIndex.medicine),
        Politics(name: "Pacifist State",   reactionIllegal: 7, strengthPolice: 2, strengthPirates: 1, strengthTraders: 5, minTechLevel: 0, maxTechLevel: 3, bribeLevel: 1, drugsOK: true,  firearmsOK: false, wanted: -1),
        Politics(name: "Socialist State",  reactionIllegal: 4, strengthPolice: 2, strengthPirates: 5, strengthTraders: 3, minTechLevel: 0, maxTechLevel: 5, bribeLevel: 6, drugsOK: true,  firearmsOK: true,  wanted: -1),
        Politics(name: "State of Satori",  reactionIllegal: 0, strengthPolice: 1, strengthPirates: 1, strengthTraders: 1, minTechLevel: 0, maxTechLevel: 1, bribeLevel: 0, drugsOK: false, firearmsOK: false, wanted: -1),
        Politics(name: "Technocracy",      reactionIllegal: 1, strengthPolice: 6, strengthPirates: 3, strengthTraders: 6, minTechLevel: 4, maxTechLevel: 7, bribeLevel: 2, drugsOK: true,  firearmsOK: true,  wanted: TradeItemIndex.water),
        Politics(name: "Theocracy",        reactionIllegal: 5, strengthPolice: 6, strengthPirates: 1, strengthTraders: 4, minTechLevel: 0, maxTechLevel: 4, bribeLevel: 0, drugsOK: true,  firearmsOK: true,  wanted: TradeItemIndex.narcotics),
    ]
}
