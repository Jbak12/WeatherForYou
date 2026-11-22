//
//  ForecastHeaderView.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import SwiftUI

struct ForecastHeaderView: View {
    let location: Location
    let forecast: Forecast

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(location.name)
                .font(.largeTitle.bold())

            if !location.subtitle.isEmpty {
                Text(location.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if let current = forecast.current {
                HStack(alignment: .top, spacing: 16) {
                    WeatherIcon(
                        code: current.weatherCode,
                        isDay: current.isDay,
                        size: 64
                    )

                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(current.temperature, format: .number.precision(.fractionLength(0)))\(forecast.units.temperature)")
                            .font(.system(.largeTitle, design: .rounded, weight: .thin))

                        Text(current.weatherCode.description)
                            .font(.headline)

                        if let apparent = current.apparentTemperature {
                            Text("Feels like \(apparent, format: .number.precision(.fractionLength(0)))\(forecast.units.temperature)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if let today = forecast.daily.first {
                    Text("H: \(today.temperatureMax, format: .number.precision(.fractionLength(0)))\(forecast.units.temperature)   L: \(today.temperatureMin, format: .number.precision(.fractionLength(0)))\(forecast.units.temperature)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
