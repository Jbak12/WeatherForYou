//
//  PreviewData.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

#if DEBUG
import Foundation

extension LocationDto {
    /// A fixed location used by SwiftUI previews.
    static let preview = LocationDto(
        id: 2_950_159,
        name: "Berlin",
        latitude: 52.52437,
        longitude: 13.41053,
        elevation: 74,
        featureCode: "PPLC",
        countryCode: "DE",
        admin1Id: 2_950_157,
        admin2Id: nil,
        admin3Id: nil,
        admin4Id: nil,
        timezone: "Europe/Berlin",
        population: 3_426_354,
        postcodes: nil,
        countryId: 2_921_044,
        country: "Germany",
        admin1: "Land Berlin",
        admin2: nil,
        admin3: nil,
        admin4: nil
    )
}

extension Forecast {
    /// A deterministic sample forecast used by SwiftUI previews.
    static var preview: Forecast {
        let timeZone = TimeZone(identifier: "Europe/Berlin") ?? .current
        let reference = Date(timeIntervalSince1970: 1_795_380_300)

        let units = Forecast.Units(
            temperature: "°C",
            windSpeed: "km/h",
            precipitation: "mm",
            humidity: "%",
            precipitationProbability: "%"
        )

        let current = Forecast.CurrentConditions(
            date: reference,
            temperature: 3.3,
            apparentTemperature: -0.5,
            humidity: 77,
            precipitation: 0,
            weatherCode: .overcast,
            windSpeed: 10.8,
            windDirection: 307,
            windGusts: 23.8,
            isDay: false
        )

        let hourlyCodes: [WeatherCode] = [
            .overcast, .overcast, .partlyCloudy,
            .clearSky, .clearSky, .mainlyClear
        ]

        let hourly = (0..<24).map { offset in
            let date = reference.addingTimeInterval(TimeInterval(offset) * 3_600)
            let hour = (offset + 1) % 24

            return Forecast.HourlyEntry(
                id: date,
                date: date,
                temperature: 3 + Double(offset % 6),
                weatherCode: hourlyCodes[offset % hourlyCodes.count],
                precipitationProbability: offset.isMultiple(of: 4) ? 10 : 0,
                windSpeed: 10.8,
                isDay: (6...18).contains(hour)
            )
        }

        let dailyCodes: [WeatherCode] = [
            .overcast, .partlyCloudy, .clearSky, .slightRain,
            .moderateRain, .heavyRain, .thunderstorm
        ]

        let daily = (0..<7).map { offset in
            let date = reference.addingTimeInterval(TimeInterval(offset) * 86_400)

            return Forecast.DailyEntry(
                id: date,
                date: date,
                weatherCode: dailyCodes[offset],
                temperatureMax: 7 + Double(offset % 3),
                temperatureMin: 1 + Double(offset % 2),
                precipitationProbabilityMax: offset.isMultiple(of: 3) ? 20 : 5,
                windSpeedMax: 18,
                sunrise: date.addingTimeInterval(7 * 3_600),
                sunset: date.addingTimeInterval(17 * 3_600)
            )
        }

        return Forecast(
            timeZone: timeZone,
            current: current,
            hourly: hourly,
            daily: daily,
            units: units
        )
    }
}

/// A `ForecastRepository` that returns the sample forecast without networking.
struct PreviewForecastRepository: ForecastRepository {
    func forecast(for location: LocationDto) async throws -> Forecast {
        .preview
    }
}

/// A `LocationRepository` that serves sample data without networking or a database.
final class PreviewLocationRepository: LocationRepository {
    private var recents: [LocationDto]

    init(recents: [LocationDto] = [.preview]) {
        self.recents = recents
    }

    func searchLocations(matching query: String) async throws -> [LocationDto] {
        query.isEmpty ? [] : [.preview]
    }

    func recentLocations(limit: Int) async throws -> [LocationDto] {
        Array(recents.prefix(limit))
    }

    func recordView(of location: LocationDto) async throws {
        recents.removeAll { $0.id == location.id }
        recents.insert(location, at: 0)
    }

    func removeRecentLocation(id: Int) async throws {
        recents.removeAll { $0.id == id }
    }

    func clearRecentLocations() async throws {
        recents.removeAll()
    }
}
#endif
