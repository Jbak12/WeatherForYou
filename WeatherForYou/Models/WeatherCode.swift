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

    var localizedDescription: LocalizedStringResource {
        switch self {
        case .unknown: "weather.unknown"
        case .clearSky: "weather.clear_sky"
        case .mainlyClear: "weather.mainly_clear"
        case .partlyCloudy: "weather.partly_cloudy"
        case .overcast: "weather.overcast"
        case .fog: "weather.fog"
        case .depositingRimeFog: "weather.depositing_rime_fog"
        case .lightDrizzle: "weather.light_drizzle"
        case .moderateDrizzle: "weather.moderate_drizzle"
        case .denseDrizzle: "weather.dense_drizzle"
        case .lightFreezingDrizzle: "weather.light_freezing_drizzle"
        case .denseFreezingDrizzle: "weather.dense_freezing_drizzle"
        case .slightRain: "weather.slight_rain"
        case .moderateRain: "weather.moderate_rain"
        case .heavyRain: "weather.heavy_rain"
        case .lightFreezingRain: "weather.light_freezing_rain"
        case .heavyFreezingRain: "weather.heavy_freezing_rain"
        case .slightSnowfall: "weather.slight_snowfall"
        case .moderateSnowfall: "weather.moderate_snowfall"
        case .heavySnowfall: "weather.heavy_snowfall"
        case .snowGrains: "weather.snow_grains"
        case .slightRainShowers: "weather.slight_rain_showers"
        case .moderateRainShowers: "weather.moderate_rain_showers"
        case .violentRainShowers: "weather.violent_rain_showers"
        case .slightSnowShowers: "weather.slight_snow_showers"
        case .heavySnowShowers: "weather.heavy_snow_showers"
        case .thunderstorm: "weather.thunderstorm"
        case .thunderstormWithSlightHail: "weather.thunderstorm_with_slight_hail"
        case .heavyThunderstorm: "weather.heavy_thunderstorm"
        case .thunderstormWithHeavyHail: "weather.thunderstorm_with_heavy_hail"
        }
    }
}
