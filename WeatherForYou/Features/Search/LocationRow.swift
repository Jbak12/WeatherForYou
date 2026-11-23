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

#Preview {
    NavigationStack {
        List {
            LocationListRow(
                model: LocationRowModel(
                    location: LocationDto(
                        id: 1,
                        name: "Warsaw",
                        latitude: 52.2297,
                        longitude: 21.0122,
                        elevation: 113,
                        featureCode: "PPLC",
                        countryCode: "PL",
                        admin1Id: nil,
                        admin2Id: nil,
                        admin3Id: nil,
                        admin4Id: nil,
                        timezone: "Europe/Warsaw",
                        population: 1_790_658,
                        postcodes: nil,
                        countryId: nil,
                        country: "Poland",
                        admin1: "Masovia",
                        admin2: nil,
                        admin3: nil,
                        admin4: nil
                    )
                )
            )
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(.backgroundPrimary)
    }
}
