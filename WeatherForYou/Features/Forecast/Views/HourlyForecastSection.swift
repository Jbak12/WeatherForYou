//
//  HourlyForecastSection.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import SwiftUI

struct HourlyForecastSection: View {
    let entries: [HourlyForecastCellModel]

    var body: some View {
        if !entries.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("forecast.hourly.title")
                    .font(.headline)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(entries) { entry in
                            HourlyForecastCell(model: entry)
                        }
                    }
                }
            }
        }
    }
}
