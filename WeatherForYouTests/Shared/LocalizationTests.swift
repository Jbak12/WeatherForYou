import XCTest
@testable import WeatherForYou

@MainActor
final class LocalizationTests: XCTestCase {
    func testEnglishCatalogResolvesSearchAndWeatherLabels() {
        XCTAssertEqual(String(localized: "search.title"), "Places")
        XCTAssertEqual(String(localized: WeatherCode.clearSky.localizedDescription), "Clear sky")
        XCTAssertEqual(WindDirection.northEast.localizedAbbreviation, "NE")
    }

    func testEnglishCatalogInterpolatesForecastTemperatures() {
        let high = "9°C"
        let low = "−2°C"
        let text = String(localized: "forecast.high_low", defaultValue: "\(high) \(low)")

        XCTAssertEqual(text, "H: 9°C   L: −2°C")
    }

    func testLocalizedServerErrorPreservesStatusAndReason() {
        let body = Data(#"{"reason":"Unavailable"}"#.utf8)
        let error = APIError.httpError(statusCode: 503, body: body)

        XCTAssertEqual(error.localizedDescription, "The server responded with status 503: Unavailable")
    }
}
