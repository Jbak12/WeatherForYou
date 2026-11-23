//
//  ForecastHeaderView.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import SwiftUI

struct ForecastHeaderView: View {
    let name: String
    let subtitle: String?
    let forecast: Forecast

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(name)
                .font(.largeTitle.bold())

            if let subtitle {
                Text(subtitle)
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(.thinMaterial, in: .rect(cornerRadius: 16))
    }
}
