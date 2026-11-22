//
//  Forecast.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import Foundation

/// A decoded forecast, normalized into values the views can display directly.
struct Forecast: Sendable, Equatable {
    let timeZone: TimeZone
    let current: CurrentConditions?
    let hourly: [HourlyEntry]
    let daily: [DailyEntry]
    let units: Units

    struct CurrentConditions: Sendable, Equatable {
        let date: Date
        let temperature: Double
        let apparentTemperature: Double?
        let humidity: Int?
        let precipitation: Double?
        let weatherCode: WeatherCode
        let windSpeed: Double?
        let windDirection: Int?
        let windGusts: Double?
        let isDay: Bool
    }

    struct HourlyEntry: Identifiable, Sendable, Equatable {
        let id: Date
        let date: Date
        let temperature: Double
        let weatherCode: WeatherCode
        let precipitationProbability: Int?
        let windSpeed: Double?
        let isDay: Bool
    }

    struct DailyEntry: Identifiable, Sendable, Equatable {
        let id: Date
        let date: Date
        let weatherCode: WeatherCode
        let temperatureMax: Double
        let temperatureMin: Double
        let precipitationProbabilityMax: Int?
        let windSpeedMax: Double?
        let sunrise: Date?
        let sunset: Date?
    }

    struct Units: Sendable, Equatable {
        let temperature: String
        let windSpeed: String
        let precipitation: String
        let humidity: String
        let precipitationProbability: String
    }
}
