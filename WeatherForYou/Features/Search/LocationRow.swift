//
//  LocationRow.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import SwiftUI

struct LocationRow: View {
    let location: Location

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(location.name)
                .font(.headline)

            if !location.subtitle.isEmpty {
                Text(location.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text(
                "\(location.latitude, format: .number.precision(.fractionLength(4))), \(location.longitude, format: .number.precision(.fractionLength(4)))"
            )
            .font(.caption)
            .monospaced()
            .foregroundStyle(.secondary)

            if let timezone = location.timezone {
                Text(timezone)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.backgroundSecondary, in: .rect(cornerRadius: 12))
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
        .listRowSeparator(.hidden)
    }
}

#Preview {
    List {
        LocationRow(
            location: Location(
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
    }
}
