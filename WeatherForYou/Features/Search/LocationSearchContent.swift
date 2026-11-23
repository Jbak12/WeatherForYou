//
//  LocationSearchContent.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import SwiftUI

struct LocationSearchContent: View {
    @ObservedObject var viewModel: LocationSearchViemodel
    let onSelect: (LocationRowModel) -> Void

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.backgroundPrimary)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            if viewModel.trimmedQuery.isEmpty, !viewModel.recentLocations.isEmpty {
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
            List(viewModel.results) { row in
                LocationListRow(model: row) { onSelect(row) }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }

    private var recentList: some View {
        List {
            Section {
                ForEach(viewModel.recentLocations) { row in
                    LocationListRow(model: row) { onSelect(row) }
                }
                .onDelete { indexSet in
                    let rows = indexSet.map { viewModel.recentLocations[$0] }

                    Task {
                        for row in rows {
                            await viewModel.removeRecentLocation(row)
                        }
                    }
                }
            } header: {
                HStack {
                    Text("Recent")

                    Spacer()

                    Button("Clear") {
                        Task { await viewModel.clearRecentLocations() }
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
        Task { await viewModel.search() }
    }
}

#Preview {
    NavigationStack {
        LocationSearchContent(
            viewModel: LocationSearchViemodel(repository: PreviewLocationRepository()),
            onSelect: { _ in }
        )
    }
}
