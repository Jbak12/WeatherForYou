//
//  GeocodingService.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import Foundation

/// Searches for locations by name.
protocol GeocodingService {
    /// Returns locations matching `text`.
    ///
    /// - Parameters:
    ///   - text: A location name or postal code, optionally followed by a
    ///     comma and a country or first-level administrative area.
    ///   - count: The maximum number of results, clamped to `1...100`.
    ///   - language: The language for localized names.
    ///   - countryCode: An optional ISO-3166-1 alpha-2 country filter.
    func search(
        _ text: String,
        count: Int,
        language: String,
        countryCode: String?
    ) async throws -> [LocationDto]
}

extension GeocodingService {
    /// Searches with the API defaults: 10 results, the current language, and
    /// no country filter.
    func search(_ text: String) async throws -> [LocationDto] {
        try await search(
            text,
            count: 10,
            language: Locale.current.language.languageCode?.identifier ?? "en",
            countryCode: nil
        )
    }
}
