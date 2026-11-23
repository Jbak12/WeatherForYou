//
//  HourlyForecastCell.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import SwiftUI

struct HourlyForecastCell: View {
    let model: HourlyForecastCellModel

    private var accessibilityID: String {
        "forecast.hourly.row.\(Int(model.id.timeIntervalSince1970))"
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(model.time)
                .font(.caption)
                .foregroundStyle(.secondary)

            WeatherIcon(model: model.icon, accessibilityID: "\(accessibilityID).icon")

            Text(model.temperature)
                .font(.subheadline.weight(.semibold))

            if let precipitation = model.precipitation {
                PrecipitationLabel(value: precipitation)
            } else {
                Text(" ")
                    .font(.caption2)
            }
        }
        .frame(minWidth: 56)
        .padding(.vertical, 8)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(accessibilityID)
    }
}

#Preview("Hourly temperatures and precipitation") {
    HStack(spacing: 8) {
        ForEach(ForecastDetailsModel.preview.hourly.prefix(2)) { entry in
            HourlyForecastCell(model: entry)
        }
    }
    .padding()
    .background(.backgroundPrimary)
}
