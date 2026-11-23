//
//  ForecastContent.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import SwiftUI

struct ForecastContent: View {
    @EnvironmentObject private var model: ForecastViewModel

    var body: some View {
        switch model.state {
        case .idle, .loading:
            ProgressView("forecast.loading")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.backgroundPrimary)
        case let .failed(message):
            ContentUnavailableView {
                Label("forecast.error.title", systemImage: "exclamationmark.triangle")
            } description: {
                Text(message)
            } actions: {
                Button("action.retry", action: retry)
            }
            .background(.backgroundPrimary)

        case let .loaded(details):
            ForecastDetailsView(model: details)
        }
    }

    private func retry() {
        Task { await model.load() }
    }
}

#Preview {
    NavigationStack {
        ForecastContent()
            .environmentObject(
                ForecastViewModel(
                    coordinates: Coordinates(latitude: 52.52437, longitude: 13.41053),
                    name: "Berlin",
                    subtitle: "Land Berlin, Germany",
                    repository: PreviewForecastRepository()
                )
            )
    }
}
