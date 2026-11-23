//
//  LocationDto.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import Foundation

/// A place returned by the Open-Meteo geocoding API.
///
/// Fields the API can omit are modeled as optionals. The API documentation
/// states that empty fields are not returned, so a missing key is expected.
struct LocationDto: Codable, Sendable, Identifiable, Equatable, Hashable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let timezone: String?
    let country: String?
    let admin1: String?
}

extension LocationDto {
    /// A short "region, country" description suitable for a list row.
    var subtitle: String {
        [admin1, country]
            .compactMap { $0 }
            .joined(separator: ", ")
    }
}
