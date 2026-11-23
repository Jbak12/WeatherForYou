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
    let elevation: Double?
    let featureCode: String?
    let countryCode: String?
    let admin1Id: Int?
    let admin2Id: Int?
    let admin3Id: Int?
    let admin4Id: Int?
    let timezone: String?
    let population: Int?
    let postcodes: [String]?
    let countryId: Int?
    let country: String?
    let admin1: String?
    let admin2: String?
    let admin3: String?
    let admin4: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case latitude
        case longitude
        case elevation
        case featureCode = "feature_code"
        case countryCode = "country_code"
        case admin1Id = "admin1_id"
        case admin2Id = "admin2_id"
        case admin3Id = "admin3_id"
        case admin4Id = "admin4_id"
        case timezone
        case population
        case postcodes
        case countryId = "country_id"
        case country
        case admin1
        case admin2
        case admin3
        case admin4
    }
}

extension LocationDto {
    /// A short "region, country" description suitable for a list row.
    var subtitle: String {
        [admin1, country]
            .compactMap { $0 }
            .joined(separator: ", ")
    }
}
