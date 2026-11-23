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
        let repository = DefaultLocationRepository(service: service)

        let locations = try await repository.searchLocations(matching: " Berlin ")

        XCTAssertEqual(service.queries, [" Berlin "])
        XCTAssertEqual(locations, [.preview])
    }

    func testLocationRepositoryPropagatesServiceError() async {
        let service = StubGeocodingService()
        service.error = APIError.invalidResponse
        let repository = DefaultLocationRepository(service: service)

        do {
            _ = try await repository.searchLocations(matching: "Berlin")
            XCTFail("Expected the service error to be rethrown.")
        } catch {
            XCTAssertTrue(error is APIError)
        }
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
    var result: [Location] = []
    var error: Error?
    private(set) var queries: [String] = []

    func search(
        _ text: String,
        count: Int,
        language: String,
        countryCode: String?
    ) async throws -> [Location] {
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
    private(set) var locations: [Location] = []

    func forecast(for location: Location) async throws -> Forecast {
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
