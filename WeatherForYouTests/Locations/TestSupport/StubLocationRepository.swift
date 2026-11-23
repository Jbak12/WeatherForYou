//
//  StubLocationRepository.swift
//  WeatherForYouTests
//
//  Created by Jakub Bakalarz on 23/11/2026.
//

import Foundation
@testable import WeatherForYou

@MainActor
final class StubLocationRepository: LocationRepository {
    var searchResults: [LocationDto] = []
    var recents: [LocationDto] = []
    var error: Error?
    private(set) var recorded: [LocationDto] = []
    private(set) var removedIDs: [Int] = []

    func searchLocations(matching query: String) async throws -> [LocationDto] {
        if let error { throw error }
        return searchResults
    }

    func recentLocations(limit: Int) async throws -> [LocationDto] {
        if let error { throw error }
        return Array(recents.prefix(limit))
    }

    func recordView(of location: LocationDto) async throws {
        if let error { throw error }
        recorded.append(location)
    }

    func removeRecentLocation(id: Int) async throws {
        if let error { throw error }
        removedIDs.append(id)
        recents.removeAll { $0.id == id }
    }

    func clearRecentLocations() async throws {
        if let error { throw error }
        recents.removeAll()
    }
}
