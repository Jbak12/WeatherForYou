//
//  RecentLocationRow.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 23/11/2026.
//

import Foundation
import GRDB

/// A persisted, recently viewed location.
struct RecentLocationRow: Codable, FetchableRecord, MutablePersistableRecord {
    static let databaseTableName = "recent_location"

    var id: Int
    var name: String
    var latitude: Double
    var longitude: Double
    var elevation: Double?
    var featureCode: String?
    var countryCode: String?
    var admin1Id: Int?
    var admin2Id: Int?
    var admin3Id: Int?
    var admin4Id: Int?
    var timezone: String?
    var population: Int?
    /// The location's postcodes, encoded as a JSON array.
    var postcodes: String?
    var countryId: Int?
    var country: String?
    var admin1: String?
    var admin2: String?
    var admin3: String?
    var admin4: String?
    var lastViewedAt: Date

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
        case lastViewedAt = "last_viewed_at"
    }
}

extension RecentLocationRow {
    init(location: Location, lastViewedAt: Date) {
        self.id = location.id
        self.name = location.name
        self.latitude = location.latitude
        self.longitude = location.longitude
        self.elevation = location.elevation
        self.featureCode = location.featureCode
        self.countryCode = location.countryCode
        self.admin1Id = location.admin1Id
        self.admin2Id = location.admin2Id
        self.admin3Id = location.admin3Id
        self.admin4Id = location.admin4Id
        self.timezone = location.timezone
        self.population = location.population
        self.postcodes = location.postcodes.flatMap { postcodes in
            guard let data = try? JSONEncoder().encode(postcodes) else { return nil }
            return String(decoding: data, as: UTF8.self)
        }
        self.countryId = location.countryId
        self.country = location.country
        self.admin1 = location.admin1
        self.admin2 = location.admin2
        self.admin3 = location.admin3
        self.admin4 = location.admin4
        self.lastViewedAt = lastViewedAt
    }

    var location: Location {
        Location(
            id: id,
            name: name,
            latitude: latitude,
            longitude: longitude,
            elevation: elevation,
            featureCode: featureCode,
            countryCode: countryCode,
            admin1Id: admin1Id,
            admin2Id: admin2Id,
            admin3Id: admin3Id,
            admin4Id: admin4Id,
            timezone: timezone,
            population: population,
            postcodes: postcodes.flatMap { encoded in
                guard let data = encoded.data(using: .utf8) else { return nil }
                return try? JSONDecoder().decode([String].self, from: data)
            },
            countryId: countryId,
            country: country,
            admin1: admin1,
            admin2: admin2,
            admin3: admin3,
            admin4: admin4
        )
    }
}
