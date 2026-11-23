//
//  OpenMeteoGeocodingService.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import Foundation
import StaticURL

/// A `GeocodingService` backed by the Open-Meteo geocoding API.
///
/// See https://open-meteo.com/en/docs/geocoding-api for the request and
/// response formats.
struct OpenMeteoGeocodingService: GeocodingService {
    private static let baseURL = #staticURL("https://geocoding-api.open-meteo.com")

    private let client: APIClient

    init(client: APIClient? = nil) {
        if let client {
            self.client = client
        } else {
            self.client = DefaultAPIClient(baseURL: Self.baseURL)
        }
    }

    func search(
        _ text: String,
        count: Int,
        language: String,
        countryCode: String?
    ) async throws -> [LocationDto] {
        let name = text.trimmingCharacters(in: .whitespacesAndNewlines)

        // The API treats empty and single-character searches as having no
        // results, so skip the network round trip.
        guard name.count >= 2 else { return [] }

        var queryItems = [
            URLQueryItem(name: "name", value: name),
            URLQueryItem(name: "count", value: String(min(max(count, 1), 100))),
            URLQueryItem(name: "language", value: language.lowercased())
        ]

        if let countryCode, !countryCode.isEmpty {
            queryItems.append(
                URLQueryItem(name: "countryCode", value: countryCode.uppercased())
            )
        }

        let request = APIRequest(path: "/v1/search", queryItems: queryItems)
        let response: LocationSearchResponse = try await client.send(request)
        return response.results
    }
}
