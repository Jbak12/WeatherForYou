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

    private let service: ForecastService

    /// Creates a model backed by the live Open-Meteo forecast service.
    init(location: Location) {
        self.location = location
        self.service = OpenMeteoForecastService()
    }

    /// Creates a model with an injected service, for previews and tests.
    init(location: Location, service: ForecastService) {
        self.location = location
        self.service = service
    }

    func load() async {
        if case .loading = state { return }

        state = .loading

        do {
            let forecast = try await service.forecast(for: location)
            state = .loaded(forecast)
        } catch is CancellationError {
            return
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
