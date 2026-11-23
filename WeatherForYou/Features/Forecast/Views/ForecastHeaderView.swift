//
//  ForecastHeaderView.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import SwiftUI

struct ForecastHeaderView: View {
    let model: ForecastHeaderModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(model.name)
                .font(.largeTitle.bold())

            if let subtitle = model.subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if let current = model.current {
                HStack(alignment: .top, spacing: 16) {
                    WeatherIcon(model: current.icon, size: 64)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(current.temperature)
                            .font(.system(.largeTitle, design: .rounded, weight: .thin))

                        Text(current.icon.accessibilityLabel)
                            .font(.headline)

                        if let feelsLike = current.feelsLike {
                            Text(feelsLike)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if let highLow = current.highLow {
                    Text(highLow)
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

#Preview("Current weather") {
    ForecastHeaderView(model: ForecastDetailsModel.preview.header)
        .padding()
        .background(.backgroundPrimary)
}

#Preview("Without current weather") {
    let sample = ForecastDetailsModel.preview.header
    ForecastHeaderView(model: ForecastHeaderModel(name: sample.name, subtitle: sample.subtitle, current: nil))
        .padding()
        .background(.backgroundPrimary)
}
