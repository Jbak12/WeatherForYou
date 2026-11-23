//
//  RecentLocationStoreTests.swift
//  WeatherForYouTests
//
//  Created by Jakub Bakalarz on 23/11/2026.
//

import GRDB
import XCTest
@testable import WeatherForYou

@MainActor
final class RecentLocationStoreTests: XCTestCase {

    func testRecordAndFetchRoundTripsLocation() async throws {
        let store = GRDBRecentLocationStore(database: try AppDatabase.inMemory())
        let location = makeLocation(id: 1, name: "Warsaw")

        try await store.record(location)
        let recents = try await store.recentLocations(limit: 10)

        XCTAssertEqual(recents, [location])
    }

    func testMigratesV1HistoryWithoutLosingRecentLocations() async throws {
        let writer = try DatabaseQueue()
        try AppDatabase.migrator.migrate(writer, upTo: "v1_recent_locations")
        let location = makeLocation(id: 1, name: "Warsaw")
        let locationID = location.id
        let viewedAt = Date(timeIntervalSince1970: 1_800_000_000)
        let arguments: StatementArguments = [
            locationID, location.name, location.latitude, location.longitude,
            location.timezone, location.country, location.admin1, viewedAt, "[\"00-001\"]"
        ]

        try await writer.write { db in
            try db.execute(
                sql: """
                    INSERT INTO recent_location
                    (id, name, latitude, longitude, timezone, country, admin1, last_viewed_at, postcodes)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                    """,
                arguments: arguments
            )
        }

        let database = try AppDatabase(writer)
        let store = GRDBRecentLocationStore(database: database)
        let recents = try await store.recentLocations(limit: 10)
        XCTAssertEqual(recents, [location])

        let (columns, savedDate) = try await writer.read { db in
            let columns = try db.columns(in: "recent_location").map(\.name)
            let savedDate = try RecentLocationRecord.fetchOne(db, key: locationID)?.lastViewedAt
            return (columns, savedDate)
        }
        XCTAssertEqual(Set(columns), ["id", "name", "latitude", "longitude", "timezone", "country", "admin1", "last_viewed_at"])
        XCTAssertEqual(savedDate, viewedAt)
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

    private func makeLocation(id: Int, name: String) -> LocationDto {
        LocationDto(
            id: id,
            name: name,
            latitude: 52.2297,
            longitude: 21.0122,
            timezone: "Europe/Warsaw",
            country: "Poland",
            admin1: "Masovia"
        )
    }
}
