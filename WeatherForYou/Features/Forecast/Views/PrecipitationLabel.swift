import SwiftUI

struct PrecipitationLabel: View {
    let value: String

    var body: some View {
        Label(value, systemImage: "drop.fill")
            .font(.caption2)
            .foregroundStyle(.bluePrimary)
    }
}
