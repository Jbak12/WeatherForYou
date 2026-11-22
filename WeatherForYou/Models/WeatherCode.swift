//
//  WeatherCode.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import Foundation

/// WMO weather interpretation codes returned by Open-Meteo.
///
/// See https://open-meteo.com/en/docs#weather_variable_documentation
enum WeatherCode: Int, Sendable {
    case unknown = -1
    case clearSky = 0
    case mainlyClear = 1
    case partlyCloudy = 2
    case overcast = 3
    case fog = 45
    case depositingRimeFog = 48
    case lightDrizzle = 51
    case moderateDrizzle = 53
    case denseDrizzle = 55
    case lightFreezingDrizzle = 56
    case denseFreezingDrizzle = 57
    case slightRain = 61
    case moderateRain = 63
    case heavyRain = 65
    case lightFreezingRain = 66
    case heavyFreezingRain = 67
    case slightSnowfall = 71
    case moderateSnowfall = 73
    case heavySnowfall = 75
    case snowGrains = 77
    case slightRainShowers = 80
    case moderateRainShowers = 81
    case violentRainShowers = 82
    case slightSnowShowers = 85
    case heavySnowShowers = 86
    case thunderstorm = 95
    case thunderstormWithSlightHail = 96
    case heavyThunderstorm = 97
    case thunderstormWithHeavyHail = 99

    init(code: Int) {
        self = WeatherCode(rawValue: code) ?? .unknown
    }

    var description: String {
        switch self {
        case .unknown: "Unknown"
        case .clearSky: "Clear sky"
        case .mainlyClear: "Mainly clear"
        case .partlyCloudy: "Partly cloudy"
        case .overcast: "Overcast"
        case .fog: "Fog"
        case .depositingRimeFog: "Depositing rime fog"
        case .lightDrizzle: "Light drizzle"
        case .moderateDrizzle: "Moderate drizzle"
        case .denseDrizzle: "Dense drizzle"
        case .lightFreezingDrizzle: "Light freezing drizzle"
        case .denseFreezingDrizzle: "Dense freezing drizzle"
        case .slightRain: "Slight rain"
        case .moderateRain: "Moderate rain"
        case .heavyRain: "Heavy rain"
        case .lightFreezingRain: "Light freezing rain"
        case .heavyFreezingRain: "Heavy freezing rain"
        case .slightSnowfall: "Slight snowfall"
        case .moderateSnowfall: "Moderate snowfall"
        case .heavySnowfall: "Heavy snowfall"
        case .snowGrains: "Snow grains"
        case .slightRainShowers: "Slight rain showers"
        case .moderateRainShowers: "Moderate rain showers"
        case .violentRainShowers: "Violent rain showers"
        case .slightSnowShowers: "Slight snow showers"
        case .heavySnowShowers: "Heavy snow showers"
        case .thunderstorm: "Thunderstorm"
        case .thunderstormWithSlightHail: "Thunderstorm with slight hail"
        case .heavyThunderstorm: "Heavy thunderstorm"
        case .thunderstormWithHeavyHail: "Thunderstorm with heavy hail"
        }
    }
}
