//
//  DailyForecastSection.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import SwiftUI

struct DailyForecastSection: View {
    let entries: [Forecast.DailyEntry]
    let timeZone: TimeZone

    var body: some View {
        if !entries.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("7-day forecast")
                    .font(.headline)

                VStack(spacing: 0) {
                    ForEach(entries) { entry in
                        DailyForecastRow(
                            entry: entry,
                            timeZone: timeZone,
                            isToday: entry.id == entries.first?.id
                        )

                        if entry.id != entries.last?.id {
                            Divider()
                        }
                    }
                }
            }
        }
    }
}
