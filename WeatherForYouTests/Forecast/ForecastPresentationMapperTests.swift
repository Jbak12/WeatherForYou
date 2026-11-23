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
        XCTAssertEqual(model.hourly.dropFirst().first?.precipitation, "0%")
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

    func testWholeDegreesDropMinusSignOnlyWhenRoundedToZero() {
        let now = Date(timeIntervalSince1970: 1_795_380_300)
        let hourly = [-0.2, -0.0, -0.6].enumerated().map { index, temperature in
            let date = now.addingTimeInterval(Double(index) * 3_600)
            return Forecast.HourlyEntry(
                id: date, date: date, temperature: temperature, weatherCode: .clearSky,
                precipitationProbability: nil, windSpeed: nil, isDay: true
            )
        }
        let forecast = Forecast(
            timeZone: .gmt, current: nil, hourly: hourly, daily: [], units: Forecast.preview.units
        )

        XCTAssertEqual(map(forecast, now: now).hourly.map(\.temperature), ["0°", "0°", "-1°"])
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
