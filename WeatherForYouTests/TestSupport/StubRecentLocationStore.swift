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
    var locations: [LocationDto] = []
    var error: Error?
    private(set) var recorded: [LocationDto] = []
    private(set) var removedIDs: [Int] = []

    func recentLocations(limit: Int) async throws -> [LocationDto] {
        if let error { throw error }
        return Array(locations.prefix(limit))
    }

    func record(_ location: LocationDto) async throws {
        if let error { throw error }
        recorded.append(location)
    }

    func remove(locationID: Int) async throws {
        if let error { throw error }
        removedIDs.append(locationID)
        locations.removeAll { $0.id == locationID }
    }

    func clear() async throws {
        if let error { throw error }
        locations.removeAll()
    }
}
