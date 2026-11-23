import XCTest
@testable import WeatherForYou

@MainActor
final class ForecastRepositoryTests: XCTestCase {
    func testForecastRepositoryForwardsCoordinatesToService() async throws {
        let service = StubForecastService()
        service.result = .preview
        let repository = DefaultForecastRepository(service: service)

        let coordinates = Coordinates(latitude: 52.52437, longitude: 13.41053)
        let forecast = try await repository.forecast(at: coordinates)

        XCTAssertEqual(service.requests, [coordinates])
        XCTAssertEqual(forecast, .preview)
    }

    func testForecastRepositoryPropagatesServiceError() async {
        let service = StubForecastService()
        service.error = APIError.invalidResponse
        let repository = DefaultForecastRepository(service: service)

        do {
            _ = try await repository.forecast(at: Coordinates(latitude: 52.52437, longitude: 13.41053))
            XCTFail("Expected the service error to be rethrown.")
        } catch {
            XCTAssertTrue(error is APIError)
        }
    }
}

@MainActor
private final class StubForecastService: ForecastService {
    var result: Forecast?
    var error: Error?
    private(set) var requests: [Coordinates] = []

    func forecast(at coordinates: Coordinates) async throws -> Forecast {
        requests.append(coordinates)

        if let error {
            throw error
        }

        guard let result else {
            throw APIError.emptyResponse
        }

        return result
    }
}
