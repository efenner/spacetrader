// Derived from Space Trader by Pieter Spronck, GPLv2.
//
// A trade-item row used by the Buy Cargo screen. Shows the item's
// name, its unit price (or "—" when the system doesn't sell it),
// the quantity on the market, the quantity in the hold, and a
// Buy / Sell pair of steppers.

import SwiftUI

struct PriceRow: View {
    let name: String
    let unitPrice: Int
    let marketQty: Int
    let holdQty: Int
    let canBuy: Bool
    let canSell: Bool
    let onBuy: () -> Void
    let onSell: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(name).font(.headline)
                Spacer()
                Text(priceLabel).monospacedDigit()
            }
            HStack {
                Text("Market: \(marketQty)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("Hold: \(holdQty)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            HStack {
                Button("Sell 1", action: onSell)
                    .buttonStyle(.bordered)
                    .disabled(!canSell)
                Spacer()
                Button("Buy 1", action: onBuy)
                    .buttonStyle(.borderedProminent)
                    .disabled(!canBuy)
            }
        }
        .padding(.vertical, 4)
    }

    private var priceLabel: String {
        unitPrice > 0 ? "\(unitPrice) cr." : "—"
    }
}
