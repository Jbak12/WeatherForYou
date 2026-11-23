//
//  StubRecentLocationStore.swift
//  WeatherForYouTests
//
//  Created by Jakub Bakalarz on 23/11/2026.
//

import Foundation
@testable import WeatherForYou

@MainActor
final class StubRecentLocationStore: RecentLocationStore {
    var locations: [Location] = []
    var error: Error?
    private(set) var recorded: [Location] = []

    func recentLocations(limit: Int) async throws -> [Location] {
        if let error { throw error }
        return Array(locations.prefix(limit))
    }

    func record(_ location: Location) async throws {
        if let error { throw error }
        recorded.append(location)
    }

    func remove(locationID: Int) async throws {
        if let error { throw error }
        locations.removeAll { $0.id == locationID }
    }

    func clear() async throws {
        if let error { throw error }
        locations.removeAll()
    }
}
