//
//  DailyForecastRow.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import SwiftUI

struct DailyForecastRow: View {
    let model: DailyForecastRowModel

    private var accessibilityID: String {
        "forecast.daily.row.\(Int(model.id.timeIntervalSince1970))"
    }

    var body: some View {
        HStack(spacing: 12) {
            Text(model.day)
                .font(.subheadline.weight(model.isToday ? .semibold : .regular))
                .frame(width: 52, alignment: .leading)

            WeatherIcon(model: model.icon, accessibilityID: "\(accessibilityID).icon", size: 26)

            if let precipitation = model.precipitation {
                Label(precipitation, systemImage: "drop.fill")
                    .font(.caption2)
                    .foregroundStyle(.blue)
            }

            Spacer(minLength: 8)

            Text(model.minimumTemperature)
                .foregroundStyle(.secondary)
                .frame(width: 40, alignment: .trailing)

            Text(model.maximumTemperature)
                .fontWeight(.semibold)
                .frame(width: 40, alignment: .trailing)
        }
        .font(.subheadline)
        .padding(.vertical, 8)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(accessibilityID)
    }
}

#Preview("Today and tomorrow") {
    VStack(spacing: 0) {
        ForEach(ForecastDetailsModel.preview.daily.prefix(2)) { entry in
            DailyForecastRow(model: entry)
        }
    }
    .padding()
    .background(.backgroundPrimary)
}
