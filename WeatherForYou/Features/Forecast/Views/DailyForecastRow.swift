//
//  DailyForecastRow.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import SwiftUI

struct DailyForecastRow: View {
    let model: DailyForecastRowModel

    var body: some View {
        HStack(spacing: 12) {
            Text(model.day)
                .font(.subheadline.weight(model.isToday ? .semibold : .regular))
                .frame(width: 52, alignment: .leading)

            WeatherIcon(model: model.icon, size: 26)

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
    }

}
