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
    let location: LocationDto

    private let repository: ForecastRepository
    private let locationRepository: LocationRepository

    /// Creates a model backed by the default repositories.
    init(location: LocationDto) {
        self.location = location
        self.repository = DefaultForecastRepository()
        self.locationRepository = DefaultLocationRepository()
    }

    /// Creates a model with injected dependencies, for previews and tests.
    init(
        location: LocationDto,
        repository: ForecastRepository,
        locationRepository: LocationRepository
    ) {
        self.location = location
        self.repository = repository
        self.locationRepository = locationRepository
    }

    func load() async {
        if case .loading = state { return }

        state = .loading

        do {
            let forecast = try await repository.forecast(for: location)
            state = .loaded(forecast)

            // Persistence is best-effort and must never break the screen.
            try? await locationRepository.recordView(of: location)
        } catch is CancellationError {
            return
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
