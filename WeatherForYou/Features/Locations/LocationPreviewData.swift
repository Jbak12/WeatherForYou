#if DEBUG
extension LocationDto {
    /// A fixed location used by SwiftUI previews.
    static let preview = LocationDto(
        id: 2_950_159,
        name: "Berlin",
        latitude: 52.52437,
        longitude: 13.41053,
        timezone: "Europe/Berlin",
        country: "Germany",
        admin1: "Land Berlin"
    )
}

/// A `LocationRepository` that serves sample data without networking or a database.
final class PreviewLocationRepository: LocationRepository {
    private var recents: [LocationDto]
    private let results: [LocationDto]

    init(recents: [LocationDto] = [.preview], results: [LocationDto] = [.preview]) {
        self.recents = recents
        self.results = results
    }

    func searchLocations(matching query: String) async throws -> [LocationDto] {
        query.isEmpty ? [] : results
    }

    func recentLocations(limit: Int) async throws -> [LocationDto] {
        Array(recents.prefix(limit))
    }

    func recordView(of location: LocationDto) async throws {
        recents.removeAll { $0.id == location.id }
        recents.insert(location, at: 0)
    }

    func removeRecentLocation(id: Int) async throws {
        recents.removeAll { $0.id == id }
    }

    func clearRecentLocations() async throws {
        recents.removeAll()
    }
}
#endif
