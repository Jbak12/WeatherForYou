//
//  HourlyForecastSection.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import SwiftUI

struct HourlyForecastSection: View {
    let entries: [Forecast.HourlyEntry]
    let timeZone: TimeZone

    var body: some View {
        if !entries.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Next 24 hours")
                    .font(.headline)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(entries) { entry in
                            HourlyForecastCell(entry: entry, timeZone: timeZone)
                        }
                    }
                }
            }
        }
    }
}
