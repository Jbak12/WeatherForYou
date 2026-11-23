//
//  LocationSearchModel.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import Foundation
import Combine

/// Drives the location search screen: owns the query, results, and load state.
@MainActor
final class LocationSearchModel: ObservableObject {
    enum State: Equatable {
        case idle
        case loading
        case loaded
        case empty
        case failed(String)
    }

    @Published var query = ""
    @Published private(set) var results: [LocationRowModel] = []
    @Published private(set) var state: State = .idle
    @Published private(set) var recentLocations: [LocationRowModel] = []

    private static let recentLimit = 10

    private let repository: LocationRepository
    private let debounce: Duration

    /// Creates a model backed by the default location repository.
    ///
    /// - Parameter debounce: How long to wait after the last keystroke before
    ///   searching.
    init(debounce: Duration = .milliseconds(300)) {
        self.repository = DefaultLocationRepository()
        self.debounce = debounce
    }

    init(repository: LocationRepository, debounce: Duration = .milliseconds(300)) {
        self.repository = repository
        self.debounce = debounce
    }

    var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Reloads the recently viewed locations.
    func loadRecentLocations() async {
        let locations = (try? await repository.recentLocations(
            limit: Self.recentLimit
        )) ?? []

        recentLocations = locations.map { LocationRowModel(location: $0) }
    }

    /// Removes a single location from the recents.
    func removeRecentLocation(_ row: LocationRowModel) async {
        do {
            try await repository.removeRecentLocation(id: row.id)
            recentLocations.removeAll { $0.id == row.id }
        } catch {
            // Keep the row visible when the deletion fails.
        }
    }

    /// Removes every recent location.
    func clearRecentLocations() async {
        do {
            try await repository.clearRecentLocations()
            recentLocations = []
        } catch {
            // Keep the rows visible when the deletion fails.
        }
    }

    /// Debounces the current query, then loads matching locations.
    ///
    /// Callers are expected to cancel in-flight searches when the query
    /// changes, for example with `.task(id: model.query)`.
    func search() async {
        let text = trimmedQuery

        guard text.count >= 2 else {
            results = []
            state = .idle
            return
        }

        do {
            try await Task.sleep(for: debounce)

            // Only show the spinner once the user has paused typing, so
            // existing results stay visible during the debounce window.
            state = .loading

            let locations = try await repository.searchLocations(matching: text)

            // The query may have changed while the request was in flight.
            guard text == trimmedQuery else { return }

            results = locations.map { LocationRowModel(location: $0) }
            state = locations.isEmpty ? .empty : .loaded
        } catch is CancellationError {
            return
        } catch {
            guard text == trimmedQuery else { return }

            results = []
            state = .failed(error.localizedDescription)
        }
    }
}
