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

    /// Creates a model backed by the default forecast repository.
    init(location: Location) {
        self.location = location
        self.repository = DefaultForecastRepository()
    }

    /// Creates a model with an injected repository, for previews and tests.
    init(location: Location, repository: ForecastRepository) {
        self.location = location
        self.repository = repository
    }

    func load() async {
        if case .loading = state { return }

        state = .loading

        do {
            let forecast = try await repository.forecast(for: location)
            state = .loaded(forecast)
        } catch is CancellationError {
            return
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
