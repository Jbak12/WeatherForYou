//
//  GeocodingServiceTests.swift
//  WeatherForYouTests
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import XCTest
@testable import WeatherForYou

@MainActor
final class GeocodingServiceTests: XCTestCase {

    // MARK: - Request building

    func testSearchBuildsExpectedQueryItems() async throws {
        let client = StubAPIClient()
        client.result = LocationSearchResponse()
        let service = OpenMeteoGeocodingService(client: client)

        _ = try await service.search(
            "Warsaw",
            count: 5,
            language: "EN",
            countryCode: "pl"
        )

        let request = try XCTUnwrap(client.requests.first)
        XCTAssertEqual(request.method, .get)
        XCTAssertEqual(request.path, "/v1/search")
        XCTAssertEqual(value(of: "name", in: request), "Warsaw")
        XCTAssertEqual(value(of: "count", in: request), "5")
        XCTAssertEqual(value(of: "language", in: request), "en")
        XCTAssertEqual(value(of: "countryCode", in: request), "PL")
    }

    func testSearchTrimsWhitespaceFromName() async throws {
        let client = StubAPIClient()
        client.result = LocationSearchResponse()
        let service = OpenMeteoGeocodingService(client: client)

        _ = try await service.search(
            "  Paris  ",
            count: 10,
            language: "en",
            countryCode: nil
        )

        let request = try XCTUnwrap(client.requests.first)
        XCTAssertEqual(value(of: "name", in: request), "Paris")
    }

    func testSearchOmitsCountryCodeWhenNotProvided() async throws {
        let client = StubAPIClient()
        client.result = LocationSearchResponse()
        let service = OpenMeteoGeocodingService(client: client)

        _ = try await service.search(
            "Berlin",
            count: 10,
            language: "en",
            countryCode: nil
        )

        let request = try XCTUnwrap(client.requests.first)
        XCTAssertNil(value(of: "countryCode", in: request))
    }

    func testSearchClampsCountToValidRange() async throws {
        let client = StubAPIClient()
        client.result = LocationSearchResponse()
        let service = OpenMeteoGeocodingService(client: client)

        _ = try await service.search("Oslo", count: 0, language: "en", countryCode: nil)
        _ = try await service.search("Oslo", count: 500, language: "en", countryCode: nil)

        XCTAssertEqual(value(of: "count", in: client.requests[0]), "1")
        XCTAssertEqual(value(of: "count", in: client.requests[1]), "100")
    }

    func testSearchSkipsNetworkForShortInput() async throws {
        let client = StubAPIClient()
        let service = OpenMeteoGeocodingService(client: client)

        let results = try await service.search(
            " A ",
            count: 10,
            language: "en",
            countryCode: nil
        )

        XCTAssertTrue(results.isEmpty)
        XCTAssertTrue(client.requests.isEmpty)
    }

    // MARK: - Decoding

    func testDecodesResultWithOmittedFields() throws {
        let json = """
        {
            "results": [
                {
                    "id": 2950159,
                    "name": "Berlin",
                    "latitude": 52.52437,
                    "longitude": 13.41053,
                    "country_code": "DE",
                    "timezone": "Europe/Berlin",
                    "country": "Germany",
                    "admin1": "Berlin"
                }
            ]
        }
        """

        let response = try JSONDecoder().decode(
            LocationSearchResponse.self,
            from: Data(json.utf8)
        )

        let location = try XCTUnwrap(response.results.first)
        XCTAssertEqual(location.id, 2_950_159)
        XCTAssertEqual(location.name, "Berlin")
        XCTAssertEqual(location.countryCode, "DE")
        XCTAssertEqual(location.subtitle, "Berlin, Germany")
        XCTAssertNil(location.elevation)
        XCTAssertNil(location.admin2)
        XCTAssertNil(location.postcodes)
    }

    func testDecodesMissingResultsAsEmpty() throws {
        let response = try JSONDecoder().decode(
            LocationSearchResponse.self,
            from: Data("{}".utf8)
        )

        XCTAssertTrue(response.results.isEmpty)
    }

    // MARK: - Errors

    func testSearchPropagatesClientError() async {
        let client = StubAPIClient()
        client.error = APIError.httpError(statusCode: 400, body: nil)
        let service = OpenMeteoGeocodingService(client: client)

        do {
            _ = try await service.search(
                "Atlantis",
                count: 10,
                language: "en",
                countryCode: nil
            )
            XCTFail("Expected the client error to be rethrown.")
        } catch {
            XCTAssertTrue(error is APIError)
        }
    }

    // MARK: - Model

    func testModelResetsToIdleForShortQuery() async {
        let client = StubAPIClient()
        client.result = LocationSearchResponse()
        let model = LocationSearchViemodel(
            repository: DefaultLocationRepository(
                service: OpenMeteoGeocodingService(client: client),
                recentStore: StubRecentLocationStore()
            ),
            debounce: .zero
        )

        model.query = "A"
        await model.search()

        XCTAssertEqual(model.state, .idle)
        XCTAssertTrue(model.results.isEmpty)
        XCTAssertTrue(client.requests.isEmpty)
    }

    func testModelReportsEmptyPhaseWhenNoResults() async {
        let client = StubAPIClient()
        client.result = LocationSearchResponse()
        let model = LocationSearchViemodel(
            repository: DefaultLocationRepository(
                service: OpenMeteoGeocodingService(client: client),
                recentStore: StubRecentLocationStore()
            ),
            debounce: .zero
        )

        model.query = "Nowhere"
        await model.search()

        XCTAssertEqual(model.state, .empty)
        XCTAssertTrue(model.results.isEmpty)
    }

    // MARK: - Helpers

    private func value(of name: String, in request: APIRequest) -> String? {
        request.queryItems.first { $0.name == name }?.value
    }
}
