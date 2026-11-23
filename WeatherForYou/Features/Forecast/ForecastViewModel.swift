//
//  ForecastViewModel.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import Foundation
import Combine

/// Drives the forecast screen for a single location.
@MainActor
final class ForecastViewModel: ObservableObject {
    enum State {
        case idle
        case loading
        case loaded(Forecast)
        case failed(String)
    }

    @Published private(set) var state: State = .idle
    let location: Location

    private let repository: ForecastRepository
    private let recentStore: RecentLocationStore

    /// Creates a model backed by the default forecast repository.
    init(location: Location) {
        self.location = location
        self.repository = DefaultForecastRepository()
        self.recentStore = GRDBRecentLocationStore.live
    }

    /// Creates a model with injected dependencies, for previews and tests.
    init(
        location: Location,
        repository: ForecastRepository,
        recentStore: RecentLocationStore
    ) {
        self.location = location
        self.repository = repository
        self.recentStore = recentStore
    }

    func load() async {
        if case .loading = state { return }

        state = .loading

        do {
            let forecast = try await repository.forecast(for: location)
            state = .loaded(forecast)

            // Persistence is best-effort and must never break the screen.
            try? await recentStore.record(location)
        } catch is CancellationError {
            return
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
