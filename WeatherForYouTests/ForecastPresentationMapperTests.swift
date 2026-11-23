import XCTest
@testable import WeatherForYou

@MainActor
final class ForecastPresentationMapperTests: XCTestCase {
    func testFormatsTemperaturesAndWeatherLabels() throws {
        let forecast = Forecast.preview
        let now = try XCTUnwrap(forecast.current?.date)
        let model = map(forecast, now: now)

        XCTAssertEqual(model.header.current?.temperature, "3°C")
        XCTAssertEqual(model.header.current?.highLow, "H: 7°C   L: 1°C")
        XCTAssertEqual(model.header.current?.icon.accessibilityLabel, "Overcast")
        XCTAssertEqual(model.currentConditions?.wind, "11 km/h NW")
        XCTAssertEqual(model.hourly.first?.precipitation, "10%")
        XCTAssertNil(model.hourly.dropFirst().first?.precipitation)
    }

    func testTodayUsesForecastTimeZoneInsteadOfFirstRow() throws {
        let forecast = Forecast.preview
        let reference = try XCTUnwrap(forecast.current?.date)
        // 23:15 UTC, but already 00:15 the next day in Berlin.
        let model = map(forecast, now: reference.addingTimeInterval(9_000))

        XCTAssertEqual(model.daily.filter(\.isToday).map(\.id), Array(forecast.daily.dropFirst().prefix(1).map(\.id)))
        XCTAssertEqual(model.daily.first(where: \.isToday)?.day, "Today")
        XCTAssertEqual(model.header.current?.highLow, "H: 8°C   L: 2°C")
    }

    func testFormatsMeasurementsUsingSuppliedLocale() throws {
        let forecast = Forecast.preview
        let now = try XCTUnwrap(forecast.current?.date)
        let mapper = ForecastPresentationMapper(locale: Locale(identifier: "de_DE"), now: now)
        let model = mapper.map(forecast, name: "Berlin", subtitle: nil)

        XCTAssertEqual(model.currentConditions?.precipitation, "0,0 mm")
    }

    private func map(_ forecast: Forecast, now: Date) -> ForecastDetailsModel {
        ForecastPresentationMapper(locale: Locale(identifier: "en_US"), now: now)
            .map(forecast, name: "Berlin", subtitle: nil)
    }
}
