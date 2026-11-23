//
//  ContentView.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 18/11/2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var model = LocationSearchModel()
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
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
        .task {
            await model.loadRecentLocations()
        }
        .task(id: model.query) {
            await model.search()
        }
        .onChange(of: path.count) { _, count in
            // A city is recorded when its details load; refresh recents when
            // the user returns to the search screen.
            guard count == 0 else { return }

            Task { await model.loadRecentLocations() }
        }
    }
}

#Preview {
    ContentView()
}
