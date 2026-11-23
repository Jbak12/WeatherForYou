//
//  WindDirection.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import Foundation

/// A compass direction derived from the wind direction in degrees.
enum WindDirection: String, CaseIterable, Sendable {
    case north = "N"
    case northEast = "NE"
    case east = "E"
    case southEast = "SE"
    case south = "S"
    case southWest = "SW"
    case west = "W"
    case northWest = "NW"

    var localizedAbbreviation: String {
        String(localized: abbreviationResource)
    }

    var abbreviationResource: LocalizedStringResource {
        switch self {
        case .north: "wind.north"
        case .northEast: "wind.northeast"
        case .east: "wind.east"
        case .southEast: "wind.southeast"
        case .south: "wind.south"
        case .southWest: "wind.southwest"
        case .west: "wind.west"
        case .northWest: "wind.northwest"
        }
    }

    init(degrees: Int) {
        let normalized = ((degrees % 360) + 360) % 360
        let index = Int((Double(normalized) / 45).rounded()) % 8
        self = Self.allCases[index]
    }
}
