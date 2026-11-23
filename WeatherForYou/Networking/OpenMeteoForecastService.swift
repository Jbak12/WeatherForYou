//
//  OpenMeteoForecastService.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import Foundation
import StaticURL

/// A `ForecastService` backed by the Open-Meteo forecast API.
///
/// See https://open-meteo.com/en/docs for the request and response formats.
struct OpenMeteoForecastService: ForecastService {
    private static let baseURL: URL = #staticURL("https://api.open-meteo.com")

    private static let currentVariables = [
        "temperature_2m",
        "relative_humidity_2m",
        "apparent_temperature",
        "is_day",
        "precipitation",
        "weather_code",
        "wind_speed_10m",
        "wind_direction_10m",
        "wind_gusts_10m"
    ].joined(separator: ",")

    private static let hourlyVariables = [
        "temperature_2m",
        "weather_code",
        "precipitation_probability",
        "wind_speed_10m",
        "is_day"
    ].joined(separator: ",")

    private static let dailyVariables = [
        "weather_code",
        "temperature_2m_max",
        "temperature_2m_min",
        "sunrise",
        "sunset",
        "precipitation_probability_max",
        "wind_speed_10m_max"
    ].joined(separator: ",")

    private let client: APIClient

    init(
        client: APIClient = DefaultAPIClient(baseURL: Self.baseURL)
    ) {
        self.client = client
    }

    func forecast(at coordinates: Coordinates) async throws -> Forecast {
        let request = APIRequest(
            path: "/v1/forecast",
            queryItems: [
                URLQueryItem(name: "latitude", value: String(coordinates.latitude)),
                URLQueryItem(name: "longitude", value: String(coordinates.longitude)),
                URLQueryItem(name: "current", value: Self.currentVariables),
                URLQueryItem(name: "hourly", value: Self.hourlyVariables),
                URLQueryItem(name: "daily", value: Self.dailyVariables),
                URLQueryItem(name: "timezone", value: "auto"),
                URLQueryItem(name: "forecast_days", value: "7"),
                URLQueryItem(name: "timeformat", value: "unixtime")
            ]
        )

        let response: ForecastDto = try await client.send(request)
        return makeForecast(from: response)
    }
}

private extension OpenMeteoForecastService {
    func makeForecast(from response: ForecastDto) -> Forecast {
        let timeZone = TimeZone(identifier: response.timezone) ?? .current

        let units = Forecast.Units(
            temperature: response.currentUnits?["temperature_2m"] ?? "°C",
            windSpeed: response.currentUnits?["wind_speed_10m"] ?? "km/h",
            precipitation: response.currentUnits?["precipitation"] ?? "mm",
            humidity: response.currentUnits?["relative_humidity_2m"] ?? "%",
            precipitationProbability: response.hourlyUnits?["precipitation_probability"] ?? "%"
        )

        return Forecast(
            timeZone: timeZone,
            current: makeCurrent(response.current),
            hourly: makeHourly(response.hourly),
            daily: makeDaily(response.daily),
            units: units
        )
    }

    func makeCurrent(
        _ dto: ForecastDto.Current?
    ) -> Forecast.CurrentConditions? {
        guard let dto, let temperature = dto.temperature2m else { return nil }

        return Forecast.CurrentConditions(
            date: Date(timeIntervalSince1970: TimeInterval(dto.time)),
            temperature: temperature,
            apparentTemperature: dto.apparentTemperature,
            humidity: dto.relativeHumidity2m,
            precipitation: dto.precipitation,
            weatherCode: WeatherCode(code: dto.weatherCode ?? -1),
            windSpeed: dto.windSpeed10m,
            windDirection: dto.windDirection10m,
            windGusts: dto.windGusts10m,
            isDay: (dto.isDay ?? 1) == 1
        )
    }

    func makeHourly(
        _ dto: ForecastDto.Hourly?
    ) -> [Forecast.HourlyEntry] {
        guard let dto else { return [] }

        let temperatures = dto.temperature2m ?? []
        let weatherCodes = dto.weatherCode ?? []
        let probabilities = dto.precipitationProbability ?? []
        let windSpeeds = dto.windSpeed10m ?? []
        let isDayValues = dto.isDay ?? []

        return dto.time.indices.compactMap { index -> Forecast.HourlyEntry? in
            guard let temperature = temperatures[safe: index] ?? nil else {
                return nil
            }

            let date = Date(timeIntervalSince1970: TimeInterval(dto.time[index]))

            return Forecast.HourlyEntry(
                id: date,
                date: date,
                temperature: temperature,
                weatherCode: WeatherCode(
                    code: (weatherCodes[safe: index] ?? nil) ?? -1
                ),
                precipitationProbability: probabilities[safe: index] ?? nil,
                windSpeed: windSpeeds[safe: index] ?? nil,
                isDay: ((isDayValues[safe: index] ?? nil) ?? 1) == 1
            )
        }

    }

    func makeDaily(
        _ dto: ForecastDto.Daily?
    ) -> [Forecast.DailyEntry] {
        guard let dto else { return [] }

        let weatherCodes = dto.weatherCode ?? []
        let maxTemperatures = dto.temperature2mMax ?? []
        let minTemperatures = dto.temperature2mMin ?? []
        let sunrises = dto.sunrise ?? []
        let sunsets = dto.sunset ?? []
        let probabilities = dto.precipitationProbabilityMax ?? []
        let windSpeeds = dto.windSpeed10mMax ?? []

        return dto.time.indices.compactMap { index -> Forecast.DailyEntry? in
            guard
                let maxTemperature = maxTemperatures[safe: index] ?? nil,
                let minTemperature = minTemperatures[safe: index] ?? nil
            else {
                return nil
            }

            let date = Date(timeIntervalSince1970: TimeInterval(dto.time[index]))
            let sunrise = (sunrises[safe: index] ?? nil).map {
                Date(timeIntervalSince1970: TimeInterval($0))
            }
            let sunset = (sunsets[safe: index] ?? nil).map {
                Date(timeIntervalSince1970: TimeInterval($0))
            }

            return Forecast.DailyEntry(
                id: date,
                date: date,
                weatherCode: WeatherCode(
                    code: (weatherCodes[safe: index] ?? nil) ?? -1
                ),
                temperatureMax: maxTemperature,
                temperatureMin: minTemperature,
                precipitationProbabilityMax: probabilities[safe: index] ?? nil,
                windSpeedMax: windSpeeds[safe: index] ?? nil,
                sunrise: sunrise,
                sunset: sunset
            )
        }
    }
}
