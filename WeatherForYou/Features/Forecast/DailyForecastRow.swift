//
//  DailyForecastRow.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import SwiftUI

struct DailyForecastRow: View {
    let entry: Forecast.DailyEntry
    let timeZone: TimeZone
    let isToday: Bool

    var body: some View {
        HStack(spacing: 12) {
            Text(dayText)
                .font(.subheadline.weight(isToday ? .semibold : .regular))
                .frame(width: 52, alignment: .leading)

            WeatherIcon(code: entry.weatherCode, isDay: true, size: 26)

            if let probability = entry.precipitationProbabilityMax, probability > 0 {
                Label("\(probability)%", systemImage: "drop.fill")
                    .font(.caption2)
                    .foregroundStyle(.blue)
            }

            Spacer(minLength: 8)

            Text("\(entry.temperatureMin, format: .number.precision(.fractionLength(0)))°")
                .foregroundStyle(.secondary)
                .frame(width: 40, alignment: .trailing)

            Text("\(entry.temperatureMax, format: .number.precision(.fractionLength(0)))°")
                .fontWeight(.semibold)
                .frame(width: 40, alignment: .trailing)
        }
        .font(.subheadline)
        .padding(.vertical, 8)
    }

    private var dayText: String {
        guard !isToday else { return "Today" }

        return entry.date.formatted(
            Date.FormatStyle(timeZone: timeZone).weekday(.abbreviated)
        )
    }
}
