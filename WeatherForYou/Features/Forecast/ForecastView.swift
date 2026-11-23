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
        ForecastContent()
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
