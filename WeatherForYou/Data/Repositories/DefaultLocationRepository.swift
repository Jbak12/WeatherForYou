//
//  DefaultLocationRepository.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 23/11/2026.
//

import Foundation

/// A `LocationRepository` backed by the geocoding API.
struct DefaultLocationRepository: LocationRepository {
    private let service: GeocodingService

    /// Creates a repository backed by the live geocoding service.
    init() {
        self.service = OpenMeteoGeocodingService()
    }

    /// Creates a repository with an injected service, for tests.
    init(service: GeocodingService) {
        self.service = service
    }

    func searchLocations(matching query: String) async throws -> [Location] {
        try await service.search(query)
    }
}
