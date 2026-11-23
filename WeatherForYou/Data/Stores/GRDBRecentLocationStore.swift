//
//  GRDBRecentLocationStore.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 23/11/2026.
//

import Foundation
import GRDB

/// A `RecentLocationStore` backed by the app's GRDB database.
struct GRDBRecentLocationStore: RecentLocationStore {
    /// The store backed by the shared on-disk database.
    static let live = GRDBRecentLocationStore(database: AppDatabase.shared)

    private let database: AppDatabase?
    private let now: () -> Date

    /// Creates a store. Pass `nil` to disable persistence gracefully.
    init(database: AppDatabase?, now: @escaping () -> Date = { .now }) {
        self.database = database
        self.now = now
    }

    func recentLocations(limit: Int) async throws -> [Location] {
        guard let database else { return [] }

        return try await database.writer.read { db in
            try RecentLocationRow
                .order(Column("last_viewed_at").desc)
                .limit(limit)
                .fetchAll(db)
                .map(\.location)
        }
    }

    func record(_ location: Location) async throws {
        guard let database else { return }

        let row = RecentLocationRow(location: location, lastViewedAt: now())
        try await database.writer.write { db in
            var row = row
            try row.upsert(db)
        }
    }

    func remove(locationID: Int) async throws {
        guard let database else { return }

        try await database.writer.write { db in
            _ = try RecentLocationRow.deleteOne(db, key: locationID)
        }
    }

    func clear() async throws {
        guard let database else { return }

        try await database.writer.write { db in
            _ = try RecentLocationRow.deleteAll(db)
        }
    }
}
