//
//  CurrentConditionsCard.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import SwiftUI

struct CurrentConditionsCard: View {
    let current: Forecast.CurrentConditions
    let units: Forecast.Units

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current conditions")
                .font(.headline)

            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 12) {
                GridRow {
                    Label("Humidity", systemImage: "humidity")
                    Text(humidityText)
                }
                GridRow {
                    Label("Wind", systemImage: "wind")
                    Text(windText)
                }
                GridRow {
                    Label("Gusts", systemImage: "wind")
                    Text(gustsText)
                }
                GridRow {
                    Label("Precipitation", systemImage: "drop.fill")
                    Text(precipitationText)
                }
            }
            .font(.subheadline)
        }
//        .padding()
//        .background(.thinMaterial, in: .rect(cornerRadius: 16))
    }

    private var humidityText: String {
        current.humidity.map { "\($0)\(units.humidity)" } ?? "—"
    }

    private var windText: String {
        let speed = current.windSpeed.map {
            "\($0.formatted(.number.precision(.fractionLength(0)))) \(units.windSpeed)"
        } ?? "—"

        guard let direction = current.windDirection else { return speed }

        return "\(speed) \(WindDirection(degrees: direction).rawValue)"
    }

    private var gustsText: String {
        current.windGusts.map {
            "\($0.formatted(.number.precision(.fractionLength(0)))) \(units.windSpeed)"
        } ?? "—"
    }

    private var precipitationText: String {
        current.precipitation.map {
            "\($0.formatted(.number.precision(.fractionLength(1)))) \(units.precipitation)"
        } ?? "—"
    }
}
