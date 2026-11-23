//
//  LocationRow.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import SwiftUI

struct LocationRow: View {
    let model: LocationRowModel

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(model.name)
                .font(.headline)

            if let subtitle = model.subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text(model.coordinates)
                .font(.caption)
                .monospaced()
                .foregroundStyle(.secondary)

            if let timezone = model.timezone {
                Text(timezone)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.thinMaterial, in: .rect(cornerRadius: 12))
    }
}

#if DEBUG
#Preview("Location card") {
    LocationRow(model: LocationRowModel(location: .preview))
        .padding()
        .background(.backgroundPrimary)
}
#endif
