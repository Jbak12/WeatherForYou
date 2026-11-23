//
//  LocationSearchContent.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import SwiftUI

struct LocationSearchContent: View {
    @ObservedObject var model: LocationSearchModel

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.backgroundPrimary)
    }

    @ViewBuilder
    private var content: some View {
        switch model.state {
        case .idle:
            if model.trimmedQuery.isEmpty, !model.recentLocations.isEmpty {
                recentList
            } else {
                ContentUnavailableView(
                    "Search for a city",
                    systemImage: "magnifyingglass",
                    description: Text("Enter at least two characters to find a place.")
                )
            }
        case .loading:
            ProgressView("Searching…")
        case .empty:
            ContentUnavailableView(
                "No results",
                systemImage: "mappin.slash",
                description: Text("The search returned no places.")
            )
        case let .failed(message):
            ContentUnavailableView {
                Label("Couldn't load places", systemImage: "exclamationmark.triangle")
            } description: {
                Text(message)
            } actions: {
                Button("Try Again", action: retry)
            }
        case .loaded:
            List(model.results) { location in
                NavigationLink(value: location) {
                    LocationRow(location: location)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }

    private var recentList: some View {
        List {
            Section {
                ForEach(model.recentLocations) { location in
                    NavigationLink(value: location) {
                        LocationRow(location: location)
                    }
                }
                .onDelete { indexSet in
                    let locations = indexSet.map { model.recentLocations[$0] }

                    Task {
                        for location in locations {
                            await model.removeRecentLocation(location)
                        }
                    }
                }
            } header: {
                HStack {
                    Text("Recent")

                    Spacer()

                    Button("Clear") {
                        Task { await model.clearRecentLocations() }
                    }
                    .font(.footnote)
                    .textCase(nil)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private func retry() {
        Task { await model.search() }
    }
}

#Preview {
    NavigationStack {
        LocationSearchContent(
            model: LocationSearchModel(
                repository: PreviewLocationRepository(),
                recentStore: PreviewRecentLocationStore()
            )
        )
    }
}
