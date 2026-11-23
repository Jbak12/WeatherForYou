//
//  ForecastRepository.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 23/11/2026.
//

import Foundation

/// Provides weather forecasts.
///
/// View models depend on this protocol instead of a concrete data source, so
/// caching or persistence can be added later without touching the UI layer.
protocol ForecastRepository {
    /// Returns the forecast for `location`.
    func forecast(for location: Location) async throws -> Forecast
}
