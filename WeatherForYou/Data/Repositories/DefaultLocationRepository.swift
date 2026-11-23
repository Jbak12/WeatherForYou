//
//  DefaultLocationRepository.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 23/11/2026.
//

import Foundation

/// The default `LocationRepository`.
///
/// Composes the geocoding service (remote search) with the recent-location
/// store (local history). View models depend on the repository, not on either
/// data source, so policies such as caching or merging can be added here.
struct DefaultLocationRepository: LocationRepository {
    private let service: GeocodingService
    private let recentStore: RecentLocationStore

    /// Creates a repository backed by the live geocoding service and database.
    init() {
        self.service = OpenMeteoGeocodingService()
        self.recentStore = GRDBRecentLocationStore.live
    }

    /// Creates a repository with injected dependencies, for tests.
    init(service: GeocodingService, recentStore: RecentLocationStore) {
        self.service = service
        self.recentStore = recentStore
    }

    func searchLocations(matching query: String) async throws -> [Location] {
        try await service.search(query)
    }

    func recentLocations(limit: Int) async throws -> [Location] {
        try await recentStore.recentLocations(limit: limit)
    }

    func recordView(of location: Location) async throws {
        try await recentStore.record(location)
    }

    func removeRecentLocation(id: Int) async throws {
        try await recentStore.remove(locationID: id)
    }

    func clearRecentLocations() async throws {
        try await recentStore.clear()
    }
}
