//
//  LocationRepositoryTests.swift
//  WeatherForYouTests
//
//  Created by Jakub Bakalarz on 23/11/2026.
//

import XCTest
@testable import WeatherForYou

@MainActor
final class LocationRepositoryTests: XCTestCase {
    func testLocationRepositoryForwardsQueryToService() async throws {
        let service = StubGeocodingService()
        service.result = [.preview]
        let repository = DefaultLocationRepository(
            service: service,
            recentStore: StubRecentLocationStore()
        )

        let locations = try await repository.searchLocations(matching: " Berlin ")

        XCTAssertEqual(service.queries, [" Berlin "])
        XCTAssertEqual(locations, [.preview])
    }

    func testLocationRepositoryPropagatesServiceError() async {
        let service = StubGeocodingService()
        service.error = APIError.invalidResponse
        let repository = DefaultLocationRepository(
            service: service,
            recentStore: StubRecentLocationStore()
        )

        do {
            _ = try await repository.searchLocations(matching: "Berlin")
            XCTFail("Expected the service error to be rethrown.")
        } catch {
            XCTAssertTrue(error is APIError)
        }
    }

    func testLocationRepositoryForwardsRecentsToStore() async throws {
        let store = StubRecentLocationStore()
        store.locations = [.preview]
        let repository = DefaultLocationRepository(
            service: StubGeocodingService(),
            recentStore: store
        )

        let recents = try await repository.recentLocations(limit: 5)
        try await repository.recordView(of: .preview)
        try await repository.removeRecentLocation(id: 1)
        try await repository.clearRecentLocations()

        XCTAssertEqual(recents, [.preview])
        XCTAssertEqual(store.recorded, [.preview])
        XCTAssertEqual(store.removedIDs, [1])
        XCTAssertTrue(store.locations.isEmpty)
    }
}

@MainActor
private final class StubGeocodingService: GeocodingService {
    var result: [LocationDto] = []
    var error: Error?
    private(set) var queries: [String] = []

    func search(
        _ text: String,
        count: Int,
        language: String,
        countryCode: String?
    ) async throws -> [LocationDto] {
        queries.append(text)

        if let error {
            throw error
        }

        return result
    }
}
