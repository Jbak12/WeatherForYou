//
//  ForecastService.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import Foundation

/// Loads a weather forecast for a location.
protocol ForecastService {
    func forecast(at coordinates: Coordinates) async throws -> Forecast
}
