//
//  LocationRepository.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 23/11/2026.
//

import Foundation

/// Provides location data: remote search results and recently viewed places.
///
/// This is the app-facing data contract. It hides whether data comes from the
/// geocoding API, the local database, or both, so view models never import
/// networking or persistence types.
protocol LocationRepository {
    /// Returns locations matching `query`.
    func searchLocations(matching query: String) async throws -> [LocationDto]

    /// Returns the most recently viewed locations, newest first.
    func recentLocations(limit: Int) async throws -> [LocationDto]

    /// Records that the user viewed `location`, moving it to the top.
    func recordView(of location: LocationDto) async throws

    /// Removes a single location from the recents.
    func removeRecentLocation(id: Int) async throws

    /// Removes every recent location.
    func clearRecentLocations() async throws
}
