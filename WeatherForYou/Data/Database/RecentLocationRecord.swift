import Foundation
import GRDB

/// A location saved in Recents, including when it was last viewed.
struct RecentLocationRecord: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "recent_location"
    static var lastViewedAtColumn: Column { Column(CodingKeys.lastViewedAt.rawValue) }

    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let timezone: String?
    let country: String?
    let admin1: String?
    let lastViewedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, name, latitude, longitude, timezone, country, admin1
        case lastViewedAt = "last_viewed_at"
    }

    init(location: LocationDto, lastViewedAt: Date) {
        id = location.id
        name = location.name
        latitude = location.latitude
        longitude = location.longitude
        timezone = location.timezone
        country = location.country
        admin1 = location.admin1
        self.lastViewedAt = lastViewedAt
    }

    var location: LocationDto {
        LocationDto(
            id: id,
            name: name,
            latitude: latitude,
            longitude: longitude,
            timezone: timezone,
            country: country,
            admin1: admin1
        )
    }
}
