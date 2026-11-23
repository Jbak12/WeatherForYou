//
//  RecentLocationStoreTests.swift
//  WeatherForYouTests
//
//  Created by Jakub Bakalarz on 23/11/2026.
//

import XCTest
@testable import WeatherForYou

@MainActor
final class RecentLocationStoreTests: XCTestCase {

    func testRecordAndFetchRoundTripsLocation() async throws {
        let store = GRDBRecentLocationStore(database: try AppDatabase.inMemory())
        let location = makeLocation(
            id: 1,
            name: "Warsaw",
            postcodes: ["00-001", "00-002"]
        )

        try await store.record(location)
        let recents = try await store.recentLocations(limit: 10)

        XCTAssertEqual(recents, [location])
    }

    func testRecordingSameLocationUpdatesRecencyWithoutDuplicating() async throws {
        var now = Date(timeIntervalSince1970: 1_800_000_000)
        let store = GRDBRecentLocationStore(
            database: try AppDatabase.inMemory(),
            now: { now }
        )
        let first = makeLocation(id: 1, name: "Warsaw")
        let second = makeLocation(id: 2, name: "Berlin")

        try await store.record(first)
        now += 60
        try await store.record(second)
        now += 60
        try await store.record(first)

        let recents = try await store.recentLocations(limit: 10)

        XCTAssertEqual(recents.map(\.id), [1, 2])
    }

    func testRecentLocationsAreNewestFirstAndLimited() async throws {
        var now = Date(timeIntervalSince1970: 1_800_000_000)
        let store = GRDBRecentLocationStore(
            database: try AppDatabase.inMemory(),
            now: { now }
        )

        for id in 1...5 {
            try await store.record(makeLocation(id: id, name: "City \(id)"))
            now += 60
        }

        let recents = try await store.recentLocations(limit: 3)

        XCTAssertEqual(recents.map(\.id), [5, 4, 3])
    }

    func testRemoveDeletesOnlyMatchingLocation() async throws {
        let store = GRDBRecentLocationStore(database: try AppDatabase.inMemory())
        let first = makeLocation(id: 1, name: "Warsaw")
        let second = makeLocation(id: 2, name: "Berlin")

        try await store.record(first)
        try await store.record(second)
        try await store.remove(locationID: 1)

        let recents = try await store.recentLocations(limit: 10)

        XCTAssertEqual(recents.map(\.id), [2])
    }

    func testClearDeletesAllLocations() async throws {
        let store = GRDBRecentLocationStore(database: try AppDatabase.inMemory())

        try await store.record(makeLocation(id: 1, name: "Warsaw"))
        try await store.record(makeLocation(id: 2, name: "Berlin"))
        try await store.clear()

        let recents = try await store.recentLocations(limit: 10)

        XCTAssertTrue(recents.isEmpty)
    }

    // MARK: - Helpers

    private func makeLocation(
        id: Int,
        name: String,
        postcodes: [String]? = nil
    ) -> Location {
        Location(
            id: id,
            name: name,
            latitude: 52.2297,
            longitude: 21.0122,
            elevation: 113,
            featureCode: "PPLC",
            countryCode: "PL",
            admin1Id: 1_234,
            admin2Id: nil,
            admin3Id: nil,
            admin4Id: nil,
            timezone: "Europe/Warsaw",
            population: 1_790_658,
            postcodes: postcodes,
            countryId: 2_345,
            country: "Poland",
            admin1: "Masovia",
            admin2: nil,
            admin3: nil,
            admin4: nil
        )
    }
}
