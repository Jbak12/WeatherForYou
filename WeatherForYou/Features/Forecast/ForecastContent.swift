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
            ProgressView("Loading forecast…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case let .failed(message):
            ContentUnavailableView {
                Label("Couldn't load forecast", systemImage: "exclamationmark.triangle")
            } description: {
                Text(message)
            } actions: {
                Button("Try Again", action: retry)
            }
        case let .loaded(forecast):
            ForecastDetailsView(location: model.location, forecast: forecast)
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
                    location: .preview,
                    repository: PreviewForecastRepository(),
                    recentStore: PreviewRecentLocationStore()
                )
            )
    }
}
