//
//  HourlyForecastCell.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import SwiftUI

struct HourlyForecastCell: View {
    let model: HourlyForecastCellModel

    var body: some View {
        VStack(spacing: 8) {
            Text(model.time)
                .font(.caption)
                .foregroundStyle(.secondary)

            WeatherIcon(model: model.icon)

            Text(model.temperature)
                .font(.subheadline.weight(.semibold))

            if let precipitation = model.precipitation {
                Label(precipitation, systemImage: "drop.fill")
                    .font(.caption2)
                    .foregroundStyle(.blue)
            } else {
                Text(" ")
                    .font(.caption2)
            }
        }
        .frame(width: 56)
        .padding(.vertical, 8)
    }
}

#Preview("With and without precipitation") {
    HStack(spacing: 8) {
        ForEach(ForecastDetailsModel.preview.hourly.prefix(2)) { entry in
            HourlyForecastCell(model: entry)
        }
    }
    .padding()
    .background(.backgroundPrimary)
}
