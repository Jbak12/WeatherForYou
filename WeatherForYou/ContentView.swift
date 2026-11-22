//
//  ContentView.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 18/11/2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var model = LocationSearchModel()

    var body: some View {
        NavigationStack {
            LocationSearchContent(model: model)
                .navigationTitle("Places")
                .searchable(
                    text: $model.query,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search cities"
                )
                .navigationDestination(for: Location.self) { location in
                    ForecastView(location: location)
                }
        }
        .task(id: model.query) {
            await model.search()
        }
    }
}

#Preview {
    ContentView()
}
