//
//  LocationRowModel.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 23/11/2026.
//

import Foundation

/// The pre-formatted data a location row displays.
///
/// Every display string is ready to render, so the row view does no formatting.
struct LocationRowModel: Identifiable, Hashable, Sendable {
    let id: Int
    let name: String
    /// The "region, country" description, or `nil` when there is nothing to show.
    let subtitle: String?
    /// The formatted latitude and longitude, such as "52.2297, 21.0122".
    let coordinates: String
    let timezone: String?

    init(location: LocationDto, locale: Locale = .current) {
        let latitude = location.latitude.formatted(
            .number.precision(.fractionLength(4)).locale(locale)
        )
        let longitude = location.longitude.formatted(
            .number.precision(.fractionLength(4)).locale(locale)
        )

        self.id = location.id
        self.name = location.name
        self.subtitle = location.subtitle.isEmpty ? nil : location.subtitle
        self.coordinates = "\(latitude), \(longitude)"
        self.timezone = location.timezone
    }
}
