//
//  CurrentConditionsCard.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import SwiftUI

struct CurrentConditionsView: View {
    let current: Forecast.CurrentConditions
    let units: Forecast.Units

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("forecast.conditions.title")
                .font(.headline)

            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 12) {
                GridRow {
                    Label("forecast.conditions.humidity", systemImage: "humidity")
                    Text(humidityText)
                }
                GridRow {
                    Label("forecast.conditions.wind", systemImage: "wind")
                    Text(windText)
                }
                GridRow {
                    Label("forecast.conditions.gusts", systemImage: "wind")
                    Text(gustsText)
                }
                GridRow {
                    Label("forecast.conditions.precipitation", systemImage: "drop.fill")
                    Text(precipitationText)
                }
            }
            .font(.subheadline)
        }
    }

    private var humidityText: String {
        current.humidity.map { "\($0)\(units.humidity)" } ?? unavailableText
    }

    private var windText: String {
        let speed = current.windSpeed.map {
            "\($0.formatted(.number.precision(.fractionLength(0)))) \(units.windSpeed)"
        } ?? unavailableText

        guard let direction = current.windDirection else { return speed }

        let compass = WindDirection(degrees: direction).localizedAbbreviation
        return String(localized: "forecast.conditions.wind_value", defaultValue: "\(speed) \(compass)")
    }

    private var gustsText: String {
        current.windGusts.map {
            "\($0.formatted(.number.precision(.fractionLength(0)))) \(units.windSpeed)"
        } ?? unavailableText
    }

    private var precipitationText: String {
        current.precipitation.map {
            "\($0.formatted(.number.precision(.fractionLength(1)))) \(units.precipitation)"
        } ?? unavailableText
    }

    private var unavailableText: String {
        String(localized: "forecast.conditions.unavailable")
    }
}
