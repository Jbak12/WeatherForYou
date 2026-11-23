//
//  ContentView.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 18/11/2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var model = LocationSearchViemodel()
    @State private var path: [LocationRoute] = []
    @State private var selectedRow: LocationRowModel?

    var body: some View {
        NavigationStack(path: $path) {
            LocationSearchContent(viewModel: model, onSelect: selectLocation)
                .navigationTitle("search.title")
                .searchable(
                    text: $model.query,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: Text("search.prompt")
                )
                .navigationDestination(for: LocationRoute.self) { route in
                    switch route {
                    case let .details(latitude, longitude):
                        ForecastView(
                            coordinates: Coordinates(latitude: latitude, longitude: longitude),
                            name: selectedRow?.name ?? String(localized: "forecast.title"),
                            subtitle: selectedRow?.subtitle,
                            onLoad: model.recentLocationRecorder()
                        )
                    }
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

    private func selectLocation(_ row: LocationRowModel) {
        guard path.isEmpty, let coordinates = model.selectLocation(id: row.id) else { return }

        selectedRow = row
        path.append(.details(latitude: coordinates.latitude, longitude: coordinates.longitude))
    }
}

#Preview {
    ContentView()
}
