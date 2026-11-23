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
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("search.screen")
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            if viewModel.trimmedQuery.isEmpty, !viewModel.recentLocations.isEmpty {
                recentList
            } else {
                idleView
            }
        case .loading:
            loadingView
        case .empty:
            emptyView
        case let .failed(message):
            errorView(message: message)
        case .loaded:
            resultsList
        }
    }

    private var idleView: some View {
        ContentUnavailableView(
            "search.idle.title",
            systemImage: "magnifyingglass",
            description: Text("search.idle.message")
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("search.idle")
    }

    private var loadingView: some View {
        ProgressView("search.loading")
            .accessibilityIdentifier("search.loading")
    }

    private var emptyView: some View {
        ContentUnavailableView(
            "search.empty.title",
            systemImage: "mappin.slash",
            description: Text("search.empty.message")
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("search.empty")
    }

    private func errorView(message: String) -> some View {
        ContentUnavailableView {
            Label("search.error.title", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("action.retry", action: retry)
                .accessibilityIdentifier("search.error.retry")
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("search.error")
    }

    private var resultsList: some View {
        List(viewModel.results) { row in
            LocationListRow(model: row, accessibilityScope: "search.results") { onSelect(row) }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("search.results")
    }

    private var recentList: some View {
        List {
            Section {
                ForEach(viewModel.recentLocations) { row in
                    LocationListRow(model: row, accessibilityScope: "search.recents") { onSelect(row) }
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
                    Text("search.recents.title")

                    Spacer()

                    Button("search.recents.clear") {
                        Task { await viewModel.clearRecentLocations() }
                    }
                    .font(.footnote)
                    .textCase(nil)
                    .accessibilityIdentifier("search.recents.clear")
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("search.recents")
    }

    private func retry() {
        Task { await viewModel.search() }
    }
}

#if DEBUG
private struct LocationSearchPreview: View {
    @StateObject private var viewModel: LocationSearchViemodel

    init(query: String = "", recents: [LocationDto] = [], results: [LocationDto] = [.preview]) {
        _viewModel = StateObject(wrappedValue: Self.makeViewModel(query: query, recents: recents, results: results))
    }

    var body: some View {
        NavigationStack {
            LocationSearchContent(viewModel: viewModel, onSelect: { _ in })
                .navigationTitle("search.title")
                .searchable(
                    text: $viewModel.query,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: Text("search.prompt")
                )
        }
        .task { await viewModel.loadRecentLocations() }
        .task(id: viewModel.query) { await viewModel.search() }
    }

    private static func makeViewModel(query: String, recents: [LocationDto], results: [LocationDto]) -> LocationSearchViemodel {
        let model = LocationSearchViemodel(
            repository: PreviewLocationRepository(recents: recents, results: results),
            debounce: .zero
        )
        model.query = query
        return model
    }
}

#Preview("Idle") {
    LocationSearchPreview()
}

#Preview("Recent locations") {
    LocationSearchPreview(recents: [.preview])
}

#Preview("Search results") {
    LocationSearchPreview(query: "Berlin")
}

#Preview("No results") {
    LocationSearchPreview(query: "Unknown city", results: [])
}
#endif
