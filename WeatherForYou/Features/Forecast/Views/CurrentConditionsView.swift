//
//  CurrentConditionsCard.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import SwiftUI

struct CurrentConditionsView: View {
    let model: CurrentConditionsModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("forecast.conditions.title")
                .font(.headline)

            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 12) {
                GridRow {
                    Label("forecast.conditions.humidity", systemImage: "humidity")
                    Text(model.humidity)
                        .accessibilityIdentifier("forecast.conditions.humidity")
                }
                GridRow {
                    Label("forecast.conditions.wind", systemImage: "wind")
                    Text(model.wind)
                        .accessibilityIdentifier("forecast.conditions.wind")
                }
                GridRow {
                    Label("forecast.conditions.gusts", systemImage: "wind")
                    Text(model.gusts)
                        .accessibilityIdentifier("forecast.conditions.gusts")
                }
                GridRow {
                    Label("forecast.conditions.precipitation", systemImage: "drop.fill")
                    Text(model.precipitation)
                        .accessibilityIdentifier("forecast.conditions.precipitation")
                }
            }
            .font(.subheadline)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("forecast.conditions")
    }
}

#Preview("Current conditions") {
    if let conditions = ForecastDetailsModel.preview.currentConditions {
        CurrentConditionsView(model: conditions)
            .padding()
            .background(.backgroundPrimary)
    }
}
