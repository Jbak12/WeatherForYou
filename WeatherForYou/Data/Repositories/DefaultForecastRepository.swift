//
//  DefaultForecastRepository.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 23/11/2026.
//

import Foundation

/// A `ForecastRepository` backed by the forecast API.
struct DefaultForecastRepository: ForecastRepository {
    private let service: ForecastService

    /// Creates a repository backed by the live forecast service.
    init() {
        self.service = OpenMeteoForecastService()
    }

    /// Creates a repository with an injected service, for tests.
    init(service: ForecastService) {
        self.service = service
    }

    func forecast(for location: LocationDto) async throws -> Forecast {
        try await service.forecast(for: location)
    }
}
