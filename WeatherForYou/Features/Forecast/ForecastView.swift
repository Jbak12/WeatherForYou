//
//  ForecastView.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import SwiftUI

struct ForecastView: View {
    @StateObject private var model: ForecastViewModel
    let name: String
    let subtitle: String?

    init(
        coordinates: Coordinates,
        name: String,
        subtitle: String?,
        repository: ForecastRepository? = nil,
        onLoad: @escaping @MainActor () async -> Void = {}
    ) {
        self.name = name
        self.subtitle = subtitle
        _model = StateObject(
            wrappedValue: ForecastViewModel(
                coordinates: coordinates,
                repository: repository ?? DefaultForecastRepository(),
                onLoad: onLoad
            )
        )
    }

    var body: some View {
        ForecastContent(name: name, subtitle: subtitle)
            .environmentObject(model)
            .navigationTitle(name)
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await model.load()
            }
    }
}

#Preview {
    NavigationStack {
        ForecastView(
            coordinates: Coordinates(latitude: 52.52437, longitude: 13.41053),
            name: "Berlin",
            subtitle: "Land Berlin, Germany",
            repository: PreviewForecastRepository()
        )
    }
}
