//
//  ContentView.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 18/11/2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var locationSearchViewModel: LocationSearchViewModel
    @State private var path: [LocationRoute] = []
    @State private var selectedRow: LocationRowModel?

    init(locationRepository: LocationRepository) {
        _locationSearchViewModel = StateObject(
            wrappedValue: LocationSearchViewModel(repository: locationRepository)
        )
    }

    var body: some View {
        NavigationStack(path: $path) {
            LocationSearchContent(viewModel: locationSearchViewModel, onSelect: selectLocation)
                .navigationTitle("search.title")
                .navigationBarTitleDisplayMode(.large)
                .searchable(
                    text: $locationSearchViewModel.query,
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
                            onForecastLoaded: locationSearchViewModel.recentLocationRecorder()
                        )
                    }
                }
        }
        .task {
            await locationSearchViewModel.loadRecentLocations()
        }
        .task(id: locationSearchViewModel.query) {
            await locationSearchViewModel.search()
        }
        .onChange(of: path.count) { _, count in
            // A city is recorded when its details load; refresh recents when
            // the user returns to the search screen.
            guard count == 0 else { return }

            Task { await locationSearchViewModel.loadRecentLocations() }
        }
    }

    private func selectLocation(_ row: LocationRowModel) {
        guard path.isEmpty, let coordinates = locationSearchViewModel.selectLocation(id: row.id) else { return }

        selectedRow = row
        path.append(.details(latitude: coordinates.latitude, longitude: coordinates.longitude))
    }
}

#if DEBUG
#Preview("Recent locations") {
    ContentView(locationRepository: PreviewLocationRepository(recents: [.preview]))
}
#endif
