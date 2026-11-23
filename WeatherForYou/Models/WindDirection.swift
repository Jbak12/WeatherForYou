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
        switch self {
        case .north: String(localized: "wind.north")
        case .northEast: String(localized: "wind.northeast")
        case .east: String(localized: "wind.east")
        case .southEast: String(localized: "wind.southeast")
        case .south: String(localized: "wind.south")
        case .southWest: String(localized: "wind.southwest")
        case .west: String(localized: "wind.west")
        case .northWest: String(localized: "wind.northwest")
        }
    }

    init(degrees: Int) {
        let normalized = ((degrees % 360) + 360) % 360
        let index = Int((Double(normalized) / 45).rounded()) % 8
        self = Self.allCases[index]
    }
}
