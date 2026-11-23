//
//  DailyForecastRow.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import SwiftUI

struct DailyForecastRow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let model: DailyForecastRowModel

    private var accessibilityID: String {
        "forecast.daily.row.\(Int(model.id.timeIntervalSince1970))"
    }

    var body: some View {
        content
            .font(.subheadline)
            .padding(.vertical, 8)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(accessibilityID)
    }

    @ViewBuilder
    private var content: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 8) {
                day
                HStack(spacing: 12) { conditions }
                HStack(spacing: 12) { temperatures }
            }
        } else {
            compactRow
        }
    }

    private var compactRow: some View {
        HStack(spacing: 12) {
            day.frame(minWidth: 52, alignment: .leading)
            conditions
            Spacer(minLength: 8)
            temperatures
        }
    }

    private var day: some View {
        Text(model.day)
            .fontWeight(model.isToday ? .semibold : .regular)
    }

    @ViewBuilder
    private var conditions: some View {
        WeatherIcon(model: model.icon, accessibilityID: "\(accessibilityID).icon", size: 26)
        if let precipitation = model.precipitation {
            PrecipitationLabel(value: precipitation)
        }
    }

    @ViewBuilder
    private var temperatures: some View {
        Text(model.minimumTemperature)
            .foregroundStyle(.secondary)
            .frame(minWidth: 40, alignment: .trailing)
        Text(model.maximumTemperature)
            .fontWeight(.semibold)
            .frame(minWidth: 40, alignment: .trailing)
    }
}

#Preview("Today and tomorrow") {
    VStack(spacing: 0) {
        ForEach(ForecastDetailsModel.preview.daily.prefix(2)) { entry in
            DailyForecastRow(model: entry)
        }
    }
    .padding()
    .background(.backgroundPrimary)
}

#Preview("Narrow width, accessibility text") {
    DailyForecastSection(entries: Array(ForecastDetailsModel.preview.daily.prefix(2)))
        .padding()
        .frame(width: 320)
        .background(.backgroundPrimary)
        .environment(\.dynamicTypeSize, .accessibility3)
}
