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
    @Published private(set) var results: [Location] = []
    @Published private(set) var state: State = .idle

    private let service: GeocodingService
    private let debounce: Duration

    /// Creates a model backed by the live Open-Meteo geocoding service.
    init(debounce: Duration = .milliseconds(300)) {
        self.service = OpenMeteoGeocodingService()
        self.debounce = debounce
    }

    /// Creates a model with an injected service, for previews and tests.
    init(service: GeocodingService, debounce: Duration = .milliseconds(300)) {
        self.service = service
        self.debounce = debounce
    }

    var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
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

            let locations = try await service.search(text)

            // The query may have changed while the request was in flight.
            guard text == trimmedQuery else { return }

            results = locations
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
