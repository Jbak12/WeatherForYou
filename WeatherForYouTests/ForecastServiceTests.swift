//
//  ForecastServiceTests.swift
//  WeatherForYouTests
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import XCTest
@testable import WeatherForYou

@MainActor
final class ForecastServiceTests: XCTestCase {

    // MARK: - Request building

    func testForecastBuildsExpectedQueryItems() async throws {
        let client = StubAPIClient()
        client.result = makeResponse()
        let service = OpenMeteoForecastService(client: client, now: { .distantPast })

        _ = try await service.forecast(for: .preview)

        let request = try XCTUnwrap(client.requests.first)
        XCTAssertEqual(request.method, .get)
        XCTAssertEqual(request.path, "/v1/forecast")
        XCTAssertEqual(value(of: "latitude", in: request), "52.52437")
        XCTAssertEqual(value(of: "longitude", in: request), "13.41053")
        XCTAssertEqual(value(of: "timezone", in: request), "auto")
        XCTAssertEqual(value(of: "forecast_days", in: request), "7")
        XCTAssertEqual(value(of: "timeformat", in: request), "unixtime")

        let current = try XCTUnwrap(value(of: "current", in: request))
        XCTAssertTrue(current.contains("temperature_2m"))
        XCTAssertTrue(current.contains("is_day"))
        XCTAssertTrue(current.contains("weather_code"))
        XCTAssertTrue(current.contains("wind_direction_10m"))

        let hourly = try XCTUnwrap(value(of: "hourly", in: request))
        XCTAssertTrue(hourly.contains("temperature_2m"))
        XCTAssertTrue(hourly.contains("precipitation_probability"))
        XCTAssertTrue(hourly.contains("is_day"))

        let daily = try XCTUnwrap(value(of: "daily", in: request))
        XCTAssertTrue(daily.contains("temperature_2m_max"))
        XCTAssertTrue(daily.contains("temperature_2m_min"))
        XCTAssertTrue(daily.contains("sunrise"))
        XCTAssertTrue(daily.contains("sunset"))
    }

    // MARK: - Decoding

    func testDecodesResponseWithNullValues() throws {
        let json = """
        {
            "latitude": 52.52,
            "longitude": 13.41,
            "timezone": "Europe/Berlin",
            "utc_offset_seconds": 3600,
            "current": {
                "time": 1795380300,
                "temperature_2m": 3.3,
                "is_day": 0,
                "weather_code": 3
            },
            "hourly": {
                "time": [1795380300, 1795383900],
                "temperature_2m": [3.3, null],
                "weather_code": [3, null],
                "precipitation_probability": [null, 10],
                "wind_speed_10m": [10.8, null],
                "is_day": [0, 1]
            },
            "daily": {
                "time": [1795380300],
                "weather_code": [3],
                "temperature_2m_max": [7.0],
                "temperature_2m_min": [1.0],
                "sunrise": [1795402800],
                "sunset": [1795438800],
                "precipitation_probability_max": [null],
                "wind_speed_10m_max": [18.0]
            }
        }
        """

        let response = try JSONDecoder().decode(
            ForecastResponse.self,
            from: Data(json.utf8)
        )

        XCTAssertEqual(response.timezone, "Europe/Berlin")
        XCTAssertEqual(response.utcOffsetSeconds, 3_600)
        XCTAssertEqual(response.current?.temperature2m, 3.3)
        XCTAssertEqual(response.current?.isDay, 0)
        XCTAssertEqual(response.hourly?.temperature2m, [3.3, nil])
        XCTAssertEqual(response.hourly?.precipitationProbability, [nil, 10])
        XCTAssertEqual(response.daily?.sunrise, [1_795_402_800])
        XCTAssertEqual(response.daily?.precipitationProbabilityMax, [nil])
    }

    // MARK: - Mapping

    func testMapsResponseIntoDomainForecast() async throws {
        let client = StubAPIClient()
        client.result = makeResponse()
        let service = OpenMeteoForecastService(client: client, now: { .distantPast })

        let forecast = try await service.forecast(for: .preview)

        XCTAssertEqual(forecast.timeZone.identifier, "Europe/Berlin")
        XCTAssertEqual(forecast.hourly.count, 24)
        XCTAssertEqual(forecast.daily.count, 7)
        XCTAssertEqual(forecast.units.temperature, "°C")
        XCTAssertEqual(forecast.units.windSpeed, "km/h")

        let current = try XCTUnwrap(forecast.current)
        XCTAssertEqual(current.temperature, 3.3)
        XCTAssertEqual(current.apparentTemperature, -0.5)
        XCTAssertEqual(current.humidity, 77)
        XCTAssertEqual(current.weatherCode, .overcast)
        XCTAssertEqual(current.windDirection, 307)
        XCTAssertFalse(current.isDay)

        let firstHour = try XCTUnwrap(forecast.hourly.first)
        XCTAssertEqual(firstHour.weatherCode, .clearSky)
        XCTAssertEqual(firstHour.temperature, 3)

        let firstDay = try XCTUnwrap(forecast.daily.first)
        XCTAssertEqual(firstDay.temperatureMax, 7)
        XCTAssertEqual(firstDay.temperatureMin, 1)
        XCTAssertEqual(firstDay.precipitationProbabilityMax, 20)
        XCTAssertNotNil(firstDay.sunrise)
        XCTAssertNotNil(firstDay.sunset)
    }

    func testHourlyKeepsOnlyUpcomingHours() async throws {
        let client = StubAPIClient()
        let response = makeResponse(hourCount: 30)
        client.result = response
        let base = try XCTUnwrap(response.hourly?.time.first)
        let now = Date(timeIntervalSince1970: TimeInterval(base + 5 * 3_600))

        let service = OpenMeteoForecastService(client: client, now: { now })
        let forecast = try await service.forecast(for: .preview)

        XCTAssertEqual(forecast.hourly.count, 24)
        XCTAssertEqual(
            forecast.hourly.first?.date,
            Date(timeIntervalSince1970: TimeInterval(base + 5 * 3_600))
        )
    }

    // MARK: - View model

    func testViewModelReachesLoadedState() async {
        let repository = StubForecastRepository()
        repository.result = .preview
        let model = ForecastViewModel(
            location: .preview,
            repository: repository,
            locationRepository: StubLocationRepository()
        )

        await model.load()

        guard case let .loaded(forecast) = model.state else {
            return XCTFail("Expected the loaded state, got \(model.state).")
        }

        XCTAssertEqual(forecast, .preview)
    }

    func testViewModelReachesFailedState() async {
        let repository = StubForecastRepository()
        repository.error = APIError.invalidResponse
        let model = ForecastViewModel(
            location: .preview,
            repository: repository,
            locationRepository: StubLocationRepository()
        )

        await model.load()

        guard case let .failed(message) = model.state else {
            return XCTFail("Expected the failed state, got \(model.state).")
        }

        XCTAssertFalse(message.isEmpty)
    }

    func testViewModelRecordsLocationAfterSuccessfulLoad() async {
        let repository = StubForecastRepository()
        repository.result = .preview
        let locationRepository = StubLocationRepository()
        let model = ForecastViewModel(
            location: .preview,
            repository: repository,
            locationRepository: locationRepository
        )

        await model.load()

        XCTAssertEqual(locationRepository.recorded, [.preview])
    }

    func testViewModelDoesNotRecordLocationWhenLoadingFails() async {
        let repository = StubForecastRepository()
        repository.error = APIError.invalidResponse
        let locationRepository = StubLocationRepository()
        let model = ForecastViewModel(
            location: .preview,
            repository: repository,
            locationRepository: locationRepository
        )

        await model.load()

        XCTAssertTrue(locationRepository.recorded.isEmpty)
    }

    // MARK: - Helpers

    private func value(of name: String, in request: APIRequest) -> String? {
        request.queryItems.first { $0.name == name }?.value
    }

    private func makeResponse(
        hourCount: Int = 30,
        dayCount: Int = 7
    ) -> ForecastResponse {
        let base = 1_795_380_000

        let current = ForecastResponse.Current(
            time: base,
            interval: 900,
            temperature2m: 3.3,
            relativeHumidity2m: 77,
            apparentTemperature: -0.5,
            isDay: 0,
            precipitation: 0,
            weatherCode: 3,
            windSpeed10m: 10.8,
            windDirection10m: 307,
            windGusts10m: 23.8
        )

        let hourlyTemperatures: [Double?] = (0..<hourCount).map {
            3 + Double($0 % 6)
        }
        let hourlyWeatherCodes: [Int?] = (0..<hourCount).map {
            $0.isMultiple(of: 2) ? 0 : 3
        }
        let hourlyProbabilities: [Int?] = (0..<hourCount).map { _ in 10 }
        let hourlyWindSpeeds: [Double?] = (0..<hourCount).map { _ in 10.8 }
        let hourlyIsDay: [Int?] = (0..<hourCount).map {
            $0 % 24 < 6 ? 0 : 1
        }

        let hourly = ForecastResponse.Hourly(
            time: (0..<hourCount).map { base + $0 * 3_600 },
            temperature2m: hourlyTemperatures,
            weatherCode: hourlyWeatherCodes,
            precipitationProbability: hourlyProbabilities,
            windSpeed10m: hourlyWindSpeeds,
            isDay: hourlyIsDay
        )

        let dailyWeatherCodes: [Int?] = (0..<dayCount).map {
            $0.isMultiple(of: 2) ? 3 : 61
        }
        let dailyMaxTemperatures: [Double?] = (0..<dayCount).map {
            7 + Double($0)
        }
        let dailyMinTemperatures: [Double?] = (0..<dayCount).map {
            1 + Double($0)
        }
        let dailySunrises: [Int?] = (0..<dayCount).map {
            base + $0 * 86_400 + 7 * 3_600
        }
        let dailySunsets: [Int?] = (0..<dayCount).map {
            base + $0 * 86_400 + 17 * 3_600
        }
        let dailyProbabilities: [Int?] = (0..<dayCount).map { _ in 20 }
        let dailyWindSpeeds: [Double?] = (0..<dayCount).map { _ in 18 }

        let daily = ForecastResponse.Daily(
            time: (0..<dayCount).map { base + $0 * 86_400 },
            weatherCode: dailyWeatherCodes,
            temperature2mMax: dailyMaxTemperatures,
            temperature2mMin: dailyMinTemperatures,
            sunrise: dailySunrises,
            sunset: dailySunsets,
            precipitationProbabilityMax: dailyProbabilities,
            windSpeed10mMax: dailyWindSpeeds
        )

        return ForecastResponse(
            latitude: 52.52437,
            longitude: 13.41053,
            elevation: 74,
            timezone: "Europe/Berlin",
            timezoneAbbreviation: "CET",
            utcOffsetSeconds: 3_600,
            current: current,
            hourly: hourly,
            daily: daily,
            currentUnits: [
                "temperature_2m": "°C",
                "wind_speed_10m": "km/h",
                "precipitation": "mm",
                "relative_humidity_2m": "%"
            ],
            hourlyUnits: ["precipitation_probability": "%"],
            dailyUnits: nil
        )
    }
}

@MainActor
private final class StubForecastRepository: ForecastRepository {
    var result: Forecast?
    var error: Error?

    func forecast(for location: Location) async throws -> Forecast {
        if let error {
            throw error
        }

        guard let result else {
            throw APIError.emptyResponse
        }

        return result
    }
}
