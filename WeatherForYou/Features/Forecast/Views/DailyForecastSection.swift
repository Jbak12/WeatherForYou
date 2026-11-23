//
//  DailyForecastSection.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import SwiftUI

struct DailyForecastSection: View {
    let entries: [DailyForecastRowModel]

    var body: some View {
        if !entries.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("forecast.daily.title")
                    .font(.headline)

                VStack(spacing: 0) {
                    ForEach(entries) { entry in
                        DailyForecastRow(model: entry)

                        if entry.id != entries.last?.id {
                            Divider()
                        }
                    }
                }
            }
        }
    }
}
