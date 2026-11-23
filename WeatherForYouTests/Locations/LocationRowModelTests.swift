//
//  LocationRowModelTests.swift
//  WeatherForYouTests
//
//  Created by Jakub Bakalarz on 23/11/2026.
//

import XCTest
@testable import WeatherForYou

@MainActor
final class LocationRowModelTests: XCTestCase {

    private let locale = Locale(identifier: "en_US_POSIX")

    func testFormatsCoordinates() {
        let model = LocationRowModel(
            location: makeLocation(latitude: 52.2297, longitude: 21.0122),
            locale: locale
        )

        XCTAssertEqual(model.coordinates, "52.2297, 21.0122")
    }

    func testBuildsSubtitleFromRegionAndCountry() {
        let model = LocationRowModel(
            location: makeLocation(admin1: "Masovia", country: "Poland"),
            locale: locale
        )

        XCTAssertEqual(model.subtitle, "Masovia, Poland")
    }

    func testSubtitleIsNilWhenRegionAndCountryAreMissing() {
        let model = LocationRowModel(
            location: makeLocation(admin1: nil, country: nil),
            locale: locale
        )

        XCTAssertNil(model.subtitle)
    }

    func testPassesThroughTimezoneAndIdentity() {
        let location = makeLocation(id: 42, timezone: "Europe/Warsaw")
        let model = LocationRowModel(location: location, locale: locale)

        XCTAssertEqual(model.id, 42)
        XCTAssertEqual(model.timezone, "Europe/Warsaw")
    }

    // MARK: - Helpers

    private func makeLocation(
        id: Int = 1,
        latitude: Double = 52.2297,
        longitude: Double = 21.0122,
        admin1: String? = "Masovia",
        country: String? = "Poland",
        timezone: String? = "Europe/Warsaw"
    ) -> LocationDto {
        LocationDto(
            id: id,
            name: "Warsaw",
            latitude: latitude,
            longitude: longitude,
            timezone: timezone,
            country: country,
            admin1: admin1
        )
    }
}
