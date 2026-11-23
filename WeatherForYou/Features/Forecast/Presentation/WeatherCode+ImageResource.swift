//
//  WeatherCode+ImageResource.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import DeveloperToolsSupport

/// Maps a WMO weather code to one of the custom weather icon assets.
extension WeatherCode {
    func imageResource(isDay: Bool) -> ImageResource {
        switch self {
        case .clearSky, .mainlyClear:
            return isDay ? ._01SunLine : ._02MoonStarsLine
        case .partlyCloudy:
            return isDay ? ._03SunCloudyLine : ._04MoonCloudyLine
        case .overcast:
            return ._06CloudsLine
        case .fog, .depositingRimeFog:
            return ._15FogLine
        case .lightDrizzle, .moderateDrizzle, .denseDrizzle,
             .lightFreezingDrizzle, .denseFreezingDrizzle:
            return ._09DrizzleLine
        case .slightRain:
            return ._08WetLine
        case .moderateRain:
            return ._10ShowersLine
        case .heavyRain:
            return ._11HeavyRainLine
        case .lightFreezingRain, .heavyFreezingRain:
            return ._16HailLine
        case .slightSnowfall:
            return ._17LightSonwLine
        case .moderateSnowfall:
            return ._18ModerateSnowLine
        case .heavySnowfall:
            return ._19HeavySnowLine
        case .snowGrains:
            return ._22SnowLine
        case .slightRainShowers:
            return ._10ShowersLine
        case .moderateRainShowers:
            return ._11HeavyRainLine
        case .violentRainShowers:
            return ._12RainstomLine
        case .slightSnowShowers:
            return ._17LightSonwLine
        case .heavySnowShowers:
            return ._20SnowstormLine
        case .thunderstorm:
            return ._14ThunderstormLine
        case .thunderstormWithSlightHail, .heavyThunderstorm,
             .thunderstormWithHeavyHail:
            return ._07CloudLightningLine
        case .unknown:
            return ._28NaLine
        }
    }
}
