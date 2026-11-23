//
//  ForecastView.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import SwiftUI

struct ForecastView: View {
    @StateObject private var model: ForecastViewModel
    @State private var retryCount = 0
    let name: String

    init(
        coordinates: Coordinates,
        name: String,
        subtitle: String?,
        repository: ForecastRepository? = nil,
        onForecastLoaded: @escaping @MainActor () async -> Void = {}
    ) {
        self.name = name
        _model = StateObject(
            wrappedValue: ForecastViewModel(
                coordinates: coordinates,
                name: name,
                subtitle: subtitle,
                repository: repository ?? DefaultForecastRepository(),
                onForecastLoaded: onForecastLoaded
            )
        )
    }

    var body: some View {
        content
            .background(.backgroundPrimary)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("forecast.screen")
            .navigationTitle(name)
            .navigationBarTitleDisplayMode(.inline)
            .task(id: retryCount) {
                await model.load()
            }
    }

    @ViewBuilder
    private var content: some View {
        switch model.state {
        case .idle, .loading:
            loadingView
        case let .failed(message):
            errorView(message: message)
        case let .loaded(details):
            ForecastDetailsView(model: details)
        }
    }

    private var loadingView: some View {
        ProgressView("forecast.loading")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityIdentifier("forecast.loading")
    }

    private func errorView(message: String) -> some View {
        ContentUnavailableView {
            Label("forecast.error.title", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("action.retry") { retryCount += 1 }
                .accessibilityIdentifier("forecast.error.retry")
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("forecast.error")
    }
}

#Preview("Loading") {
    NavigationStack {
        ForecastView(
            coordinates: Coordinates(latitude: 52.52437, longitude: 13.41053),
            name: "Berlin",
            subtitle: "Land Berlin, Germany",
            repository: PreviewForecastRepository(delay: .seconds(60))
        )
    }
}

#Preview("Loaded forecast") {
    NavigationStack {
        ForecastView(
            coordinates: Coordinates(latitude: 52.52437, longitude: 13.41053),
            name: "Berlin",
            subtitle: "Land Berlin, Germany",
            repository: PreviewForecastRepository()
        )
    }
}
