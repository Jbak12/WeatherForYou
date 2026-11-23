//
//  RecentLocationStore.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 23/11/2026.
//

import Foundation

/// Persists the locations a user has viewed.
///
/// This is the persistence seam: the app currently stores recents in SQLite
/// through GRDB, and other local features can follow the same pattern.
protocol RecentLocationStore {
    /// Returns the most recently viewed locations, newest first.
    func recentLocations(limit: Int) async throws -> [Location]

    /// Records that the user viewed `location`, moving it to the top.
    func record(_ location: Location) async throws

    /// Removes a single location from the recents.
    func remove(locationID: Int) async throws

    /// Removes every recent location.
    func clear() async throws
}
