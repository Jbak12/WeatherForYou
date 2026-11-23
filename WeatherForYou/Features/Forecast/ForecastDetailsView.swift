//
//  ForecastDetailsView.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import SwiftUI

struct ForecastDetailsView: View {
    let name: String
    let subtitle: String?
    let forecast: Forecast

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ForecastHeaderView(name: name, subtitle: subtitle, forecast: forecast)

                if let current = forecast.current {
                    CurrentConditionsView(current: current, units: forecast.units)
                }

                HourlyForecastSection(
                    entries: forecast.hourly,
                    timeZone: forecast.timeZone
                )

                DailyForecastSection(
                    entries: forecast.daily,
                    timeZone: forecast.timeZone
                )
            }
            .padding()
        }
        .background(.backgroundPrimary)
        .foregroundStyle(.textPrimary)
    }
}

#Preview {
    ForecastDetailsView(name: "Berlin", subtitle: "Land Berlin, Germany", forecast: .preview)
}
