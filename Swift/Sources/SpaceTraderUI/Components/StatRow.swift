// Derived from Space Trader by Pieter Spronck, GPLv2.
//
// Label/value row used across the status-style screens. Keeps
// alignment consistent and cuts down on repeated HStack boilerplate.

import SwiftUI

struct StatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .monospacedDigit()
        }
    }
}
