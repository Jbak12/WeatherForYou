//
//  AppDatabase.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 23/11/2026.
//

import Foundation
import GRDB
import OSLog

/// The app's SQLite database, accessed through GRDB.
///
/// The database is opened once and shared. If it cannot be opened, `shared`
/// is `nil` and features that depend on persistence simply stay empty instead
/// of crashing the app.
final class AppDatabase {
    /// The on-disk database, opened lazily on first access.
    static let shared: AppDatabase? = {
        do {
            return try openDefault()
        } catch {
            Logger(
                subsystem: Bundle.main.bundleIdentifier ?? "WeatherForYou",
                category: "database"
            )
            .error("Unable to open the database: \(error.localizedDescription)")
            return nil
        }
    }()

    let writer: any DatabaseWriter

    /// Opens a database, running any pending migrations.
    init(_ writer: any DatabaseWriter) throws {
        self.writer = writer
        try Self.migrator.migrate(writer)
    }

    /// Creates a fresh in-memory database for tests and previews.
    static func inMemory() throws -> AppDatabase {
        try AppDatabase(DatabaseQueue())
    }
}

private extension AppDatabase {
    static func openDefault() throws -> AppDatabase {
        let fileManager = FileManager.default
        let folder = try fileManager
            .url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            .appending(path: "WeatherForYou", directoryHint: .isDirectory)

        try fileManager.createDirectory(at: folder, withIntermediateDirectories: true)

        let databaseQueue = try DatabaseQueue(
            path: folder.appending(path: "weather.sqlite").path
        )
        return try AppDatabase(databaseQueue)
    }

    static var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("v1_recent_locations") { db in
            try db.create(table: "recent_location") { table in
                table.column("id", .integer).primaryKey()
                table.column("name", .text).notNull()
                table.column("latitude", .double).notNull()
                table.column("longitude", .double).notNull()
                table.column("elevation", .double)
                table.column("feature_code", .text)
                table.column("country_code", .text)
                table.column("admin1_id", .integer)
                table.column("admin2_id", .integer)
                table.column("admin3_id", .integer)
                table.column("admin4_id", .integer)
                table.column("timezone", .text)
                table.column("population", .integer)
                table.column("postcodes", .text)
                table.column("country_id", .integer)
                table.column("country", .text)
                table.column("admin1", .text)
                table.column("admin2", .text)
                table.column("admin3", .text)
                table.column("admin4", .text)
                table.column("last_viewed_at", .datetime).notNull()
            }
        }

        return migrator
    }
}
