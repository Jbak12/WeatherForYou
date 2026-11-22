//
//  HourlyForecastCell.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import SwiftUI

struct HourlyForecastCell: View {
    let entry: Forecast.HourlyEntry
    let timeZone: TimeZone

    var body: some View {
        VStack(spacing: 8) {
            Text(hourText)
                .font(.caption)
                .foregroundStyle(.secondary)

            WeatherIcon(code: entry.weatherCode, isDay: entry.isDay, size: 28)

            Text("\(entry.temperature, format: .number.precision(.fractionLength(0)))°")
                .font(.subheadline.weight(.semibold))

            if let probability = entry.precipitationProbability, probability > 0 {
                Label("\(probability)%", systemImage: "drop.fill")
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

    private var hourText: String {
        entry.date.formatted(
            Date.FormatStyle(date: .omitted, time: .shortened, timeZone: timeZone)
        )
    }
}
