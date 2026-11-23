//
//  RepositoryTests.swift
//  WeatherForYouTests
//
//  Created by Jakub Bakalarz on 23/11/2026.
//

import XCTest
@testable import WeatherForYou

@MainActor
final class RepositoryTests: XCTestCase {

    // MARK: - Location

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

    // MARK: - Forecast

    func testForecastRepositoryForwardsLocationToService() async throws {
        let service = StubForecastService()
        service.result = .preview
        let repository = DefaultForecastRepository(service: service)

        let forecast = try await repository.forecast(for: .preview)

        XCTAssertEqual(service.locations, [.preview])
        XCTAssertEqual(forecast, .preview)
    }

    func testForecastRepositoryPropagatesServiceError() async {
        let service = StubForecastService()
        service.error = APIError.invalidResponse
        let repository = DefaultForecastRepository(service: service)

        do {
            _ = try await repository.forecast(for: .preview)
            XCTFail("Expected the service error to be rethrown.")
        } catch {
            XCTAssertTrue(error is APIError)
        }
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

@MainActor
private final class StubForecastService: ForecastService {
    var result: Forecast?
    var error: Error?
    private(set) var locations: [LocationDto] = []

    func forecast(for location: LocationDto) async throws -> Forecast {
        locations.append(location)

        if let error {
            throw error
        }

        guard let result else {
            throw APIError.emptyResponse
        }

        return result
    }
}
