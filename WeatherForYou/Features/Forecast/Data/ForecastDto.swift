//
//  ForecastResponse.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import Foundation

/// The JSON returned by the Open-Meteo forecast endpoint when
/// `timeformat=unixtime` is requested.
///
/// Every timestamp is an integer number of seconds since 1970, including
/// `sunrise` and `sunset`.
struct ForecastDto: Decodable, Sendable {
    let latitude: Double
    let longitude: Double
    let elevation: Double?
    let timezone: String
    let timezoneAbbreviation: String?
    let utcOffsetSeconds: Int
    let current: Current?
    let hourly: Hourly?
    let daily: Daily?
    let currentUnits: [String: String]?
    let hourlyUnits: [String: String]?
    let dailyUnits: [String: String]?

    struct Current: Decodable, Sendable {
        let time: Int
        let interval: Int?
        let temperature2m: Double?
        let relativeHumidity2m: Int?
        let apparentTemperature: Double?
        let isDay: Int?
        let precipitation: Double?
        let weatherCode: Int?
        let windSpeed10m: Double?
        let windDirection10m: Int?
        let windGusts10m: Double?

        enum CodingKeys: String, CodingKey {
            case time
            case interval
            case temperature2m = "temperature_2m"
            case relativeHumidity2m = "relative_humidity_2m"
            case apparentTemperature = "apparent_temperature"
            case isDay = "is_day"
            case precipitation
            case weatherCode = "weather_code"
            case windSpeed10m = "wind_speed_10m"
            case windDirection10m = "wind_direction_10m"
            case windGusts10m = "wind_gusts_10m"
        }
    }

    struct Hourly: Decodable, Sendable {
        let time: [Int]
        let temperature2m: [Double?]?
        let weatherCode: [Int?]?
        let precipitationProbability: [Int?]?
        let windSpeed10m: [Double?]?
        let isDay: [Int?]?

        enum CodingKeys: String, CodingKey {
            case time
            case temperature2m = "temperature_2m"
            case weatherCode = "weather_code"
            case precipitationProbability = "precipitation_probability"
            case windSpeed10m = "wind_speed_10m"
            case isDay = "is_day"
        }
    }

    struct Daily: Decodable, Sendable {
        let time: [Int]
        let weatherCode: [Int?]?
        let temperature2mMax: [Double?]?
        let temperature2mMin: [Double?]?
        let sunrise: [Int?]?
        let sunset: [Int?]?
        let precipitationProbabilityMax: [Int?]?
        let windSpeed10mMax: [Double?]?

        enum CodingKeys: String, CodingKey {
            case time
            case weatherCode = "weather_code"
            case temperature2mMax = "temperature_2m_max"
            case temperature2mMin = "temperature_2m_min"
            case sunrise
            case sunset
            case precipitationProbabilityMax = "precipitation_probability_max"
            case windSpeed10mMax = "wind_speed_10m_max"
        }
    }

    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case elevation
        case timezone
        case timezoneAbbreviation = "timezone_abbreviation"
        case utcOffsetSeconds = "utc_offset_seconds"
        case current
        case hourly
        case daily
        case currentUnits = "current_units"
        case hourlyUnits = "hourly_units"
        case dailyUnits = "daily_units"
    }
}
