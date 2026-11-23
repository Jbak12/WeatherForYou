//
//  LocationRepository.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 23/11/2026.
//

import Foundation

/// Provides location search results.
///
/// View models depend on this protocol instead of a concrete data source, so
/// caching or persistence can be added later without touching the UI layer.
protocol LocationRepository {
    /// Returns locations matching `query`.
    func searchLocations(matching query: String) async throws -> [Location]
}
