//
//  LocationSearchResponse.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import Foundation

/// The envelope returned by the Open-Meteo geocoding search endpoint.
///
/// The API omits `results` entirely when nothing matches, so decoding treats
/// a missing key as an empty array.
struct LocationSearchResponse: Decodable, Sendable {
    let results: [LocationDto]

    init(results: [LocationDto] = []) {
        self.results = results
    }
}

extension LocationSearchResponse {
    enum CodingKeys: String, CodingKey {
        case results
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        results = try container.decodeIfPresent([LocationDto].self, forKey: .results) ?? []
    }
}
