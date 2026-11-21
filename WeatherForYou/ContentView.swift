//
//  ContentView.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 18/11/2026.
//

import SwiftUI

struct dummyView: View {
    var body: some View {
        Image(._02MoonStarsLine)
            .foregroundStyle(.iconPrimary)
    }
}

struct ContentView: View {
    @State private var locations: [Location] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
//        NavigationStack {
//            content
//                .navigationTitle("Places")
//                .toolbar {
//                    ToolbarItem(placement: .primaryAction) {
//                        Button("Reload", systemImage: "arrow.clockwise") {
//                            Task { await load() }
//                        }
//                        .disabled(isLoading)
//                    }
//                }
//        }
//        .task { await load() }
        dummyView()
    }

    @ViewBuilder
    private var content: some View {
        if isLoading {
            ProgressView("Searching for Warsaw…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let errorMessage {
            ContentUnavailableView {
                Label("Couldn't load places", systemImage: "exclamationmark.triangle")
            } description: {
                Text(errorMessage)
            } actions: {
                Button("Try Again") { Task { await load() } }
            }
        } else if locations.isEmpty {
            ContentUnavailableView(
                "No results",
                systemImage: "mappin.slash",
                description: Text("The search returned no places.")
            )
        } else {
            List(locations, id: \.id) { location in
                LocationRow(location: location)
            }
        }
    }

    private func load() async {
        isLoading = true
        errorMessage = nil
        do {
            locations = try await GeolocatingApi.fetchLocationDummy()
        } catch {
            locations = []
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

private struct LocationRow: View {
    let location: Location

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(location.name)
                .font(.headline)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(coordinates)
                .font(.caption)
                .monospaced()
                .foregroundStyle(.secondary)
            Text(location.timezone)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 2)
    }

    private var subtitle: String {
        [location.admin1, location.country]
            .compactMap { $0 }
            .joined(separator: ", ")
    }

    private var coordinates: String {
        String(format: "%.4f, %.4f", location.latitude, location.longitude)
    }
}

#Preview {
    ContentView()
}
