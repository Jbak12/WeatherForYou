//
//  ForecastDetailsView.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import SwiftUI

struct ForecastDetailsView: View {
    let location: Location
    let forecast: Forecast

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ForecastHeaderView(location: location, forecast: forecast)

                if let current = forecast.current {
                    CurrentConditionsCard(current: current, units: forecast.units)
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
    ForecastDetailsView(location: .preview, forecast: .preview)
}
