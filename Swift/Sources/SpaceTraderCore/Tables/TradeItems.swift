// Derived from Space Trader by Pieter Spronck, GPLv2.
//
// Port of `TRADEITEM` + the `Tradeitem[MAXTRADEITEM]` table from
// Src/DataTypes.h:130-144 and Src/Global.c:131-143.
//
// Each entry is accessed by raw index via `TradeItemIndex.water`, etc.

import Foundation

public struct TradeItem: Sendable, Hashable {
    public let name: String
    /// Tech level required to produce this item.
    public let techProduction: Int
    /// Tech level required to use this item.
    public let techUsage: Int
    /// Tech level that produces the most of this item (peak supply).
    public let techTopProduction: Int
    /// Median price at the lowest tech level.
    public let priceLowTech: Int
    /// Price delta per +1 tech level above `techProduction`.
    public let priceInc: Int
    /// Max ± percent variance applied to the computed price.
    public let variance: Int
    /// When this system status is active, the item's price roughly doubles.
    public let doublePriceStatus: Int
    /// When this special resource is present, the item is cheap.
    /// Value `-1` (from the C) means "no cheap resource".
    public let cheapResource: Int
    /// When this special resource is present, the item is expensive.
    public let expensiveResource: Int
    /// Minimum price for in-orbit trades with traders.
    public let minTradePrice: Int
    /// Maximum price for in-orbit trades with traders.
    public let maxTradePrice: Int
    /// Round-off step for in-orbit trade prices.
    public let roundOff: Int
}

public enum TradeItems {
    public static let all: [TradeItem] = [
        TradeItem(name: "Water",     techProduction: 0, techUsage: 0, techTopProduction: 2,
                  priceLowTech:   30, priceInc:   3, variance:   4,
                  doublePriceStatus: SystemStatusIndex.drought,
                  cheapResource: Resource.lotsOfWater, expensiveResource: Resource.desert,
                  minTradePrice:   30, maxTradePrice:   50, roundOff:   1),
        TradeItem(name: "Furs",      techProduction: 0, techUsage: 0, techTopProduction: 0,
                  priceLowTech:  250, priceInc:  10, variance:  10,
                  doublePriceStatus: SystemStatusIndex.cold,
                  cheapResource: Resource.richFauna, expensiveResource: Resource.lifeless,
                  minTradePrice:  230, maxTradePrice:  280, roundOff:   5),
        TradeItem(name: "Food",      techProduction: 1, techUsage: 0, techTopProduction: 1,
                  priceLowTech:  100, priceInc:   5, variance:   5,
                  doublePriceStatus: SystemStatusIndex.cropFailure,
                  cheapResource: Resource.richSoil, expensiveResource: Resource.poorSoil,
                  minTradePrice:   90, maxTradePrice:  160, roundOff:   5),
        TradeItem(name: "Ore",       techProduction: 2, techUsage: 2, techTopProduction: 3,
                  priceLowTech:  350, priceInc:  20, variance:  10,
                  doublePriceStatus: SystemStatusIndex.war,
                  cheapResource: Resource.mineralRich, expensiveResource: Resource.mineralPoor,
                  minTradePrice:  350, maxTradePrice:  420, roundOff:  10),
        TradeItem(name: "Games",     techProduction: 3, techUsage: 1, techTopProduction: 6,
                  priceLowTech:  250, priceInc: -10, variance:   5,
                  doublePriceStatus: SystemStatusIndex.boredom,
                  cheapResource: Resource.artistic, expensiveResource: -1,
                  minTradePrice:  160, maxTradePrice:  270, roundOff:   5),
        TradeItem(name: "Firearms",  techProduction: 3, techUsage: 1, techTopProduction: 5,
                  priceLowTech: 1250, priceInc: -75, variance: 100,
                  doublePriceStatus: SystemStatusIndex.war,
                  cheapResource: Resource.warlike, expensiveResource: -1,
                  minTradePrice:  600, maxTradePrice: 1100, roundOff:  25),
        TradeItem(name: "Medicine",  techProduction: 4, techUsage: 1, techTopProduction: 6,
                  priceLowTech:  650, priceInc: -20, variance:  10,
                  doublePriceStatus: SystemStatusIndex.plague,
                  cheapResource: Resource.lotsOfHerbs, expensiveResource: -1,
                  minTradePrice:  400, maxTradePrice:  700, roundOff:  25),
        TradeItem(name: "Machines",  techProduction: 4, techUsage: 3, techTopProduction: 5,
                  priceLowTech:  900, priceInc: -30, variance:   5,
                  doublePriceStatus: SystemStatusIndex.lackOfWorkers,
                  cheapResource: -1, expensiveResource: -1,
                  minTradePrice:  600, maxTradePrice:  800, roundOff:  25),
        TradeItem(name: "Narcotics", techProduction: 5, techUsage: 0, techTopProduction: 5,
                  priceLowTech: 3500, priceInc: -125, variance: 150,
                  doublePriceStatus: SystemStatusIndex.boredom,
                  cheapResource: Resource.weirdMushrooms, expensiveResource: -1,
                  minTradePrice: 2000, maxTradePrice: 3000, roundOff:  50),
        TradeItem(name: "Robots",    techProduction: 6, techUsage: 4, techTopProduction: 7,
                  priceLowTech: 5000, priceInc: -150, variance: 100,
                  doublePriceStatus: SystemStatusIndex.lackOfWorkers,
                  cheapResource: -1, expensiveResource: -1,
                  minTradePrice: 3500, maxTradePrice: 5000, roundOff: 100),
    ]
}
