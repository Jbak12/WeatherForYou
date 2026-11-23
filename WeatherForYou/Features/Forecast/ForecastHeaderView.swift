//
//  ForecastHeaderView.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import SwiftUI

struct ForecastHeaderView: View {
    @Environment(\.locale) private var locale

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

                        Text(current.weatherCode.localizedDescription)
                            .font(.headline)

                        if let apparent = current.apparentTemperature {
                            Text(LocalizedStringResource(
                                "forecast.feels_like",
                                defaultValue: "Feels like \(temperatureText(apparent))"
                            ))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if let today = forecast.daily.first {
                    Text(LocalizedStringResource(
                        "forecast.high_low",
                        defaultValue: "H: \(temperatureText(today.temperatureMax))   L: \(temperatureText(today.temperatureMin))"
                    ))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(.thinMaterial, in: .rect(cornerRadius: 16))
    }

    private func temperatureText(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0)).locale(locale)) + forecast.units.temperature
    }
}
