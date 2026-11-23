//
//  ForecastDetailsView.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import SwiftUI

struct ForecastDetailsView: View {
    let model: ForecastDetailsModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ForecastHeaderView(model: model.header)

                if let conditions = model.currentConditions {
                    CurrentConditionsView(model: conditions)
                }

                HourlyForecastSection(entries: model.hourly)
                DailyForecastSection(entries: model.daily)
            }
            .padding()
        }
        .background(.backgroundPrimary)
        .foregroundStyle(.textPrimary)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("forecast.details")
    }
}

#Preview("Forecast details") {
    ForecastDetailsView(model: .preview)
}
