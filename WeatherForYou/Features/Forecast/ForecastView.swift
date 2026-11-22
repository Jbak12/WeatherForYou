//
//  ForecastView.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import SwiftUI

struct ForecastView: View {
    @StateObject private var model: ForecastViewModel

    init(location: Location) {
        _model = StateObject(wrappedValue: ForecastViewModel(location: location))
    }

    init(location: Location, service: ForecastService) {
        _model = StateObject(
            wrappedValue: ForecastViewModel(location: location, service: service)
        )
    }

    var body: some View {
        ForecastContent()
            .environmentObject(model)
            .navigationTitle(model.location.name)
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await model.load()
            }
    }
}

#Preview {
    NavigationStack {
        ForecastView(location: .preview, service: PreviewForecastService())
    }
}
