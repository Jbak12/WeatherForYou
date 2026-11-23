//
//  RecentLocationsModelTests.swift
//  WeatherForYouTests
//
//  Created by Jakub Bakalarz on 23/11/2026.
//

import XCTest
@testable import WeatherForYou

@MainActor
final class RecentLocationsModelTests: XCTestCase {

    func testLoadRecentLocationsPublishesStoredLocations() async {
        let repository = StubLocationRepository()
        repository.recents = [.preview]
        let model = makeModel(repository: repository)

        await model.loadRecentLocations()

        XCTAssertEqual(model.recentLocations, [.preview])
    }

    func testRemoveRecentLocationUpdatesListAndRepository() async {
        let repository = StubLocationRepository()
        repository.recents = [.preview]
        let model = makeModel(repository: repository)
        await model.loadRecentLocations()

        await model.removeRecentLocation(.preview)

        XCTAssertTrue(model.recentLocations.isEmpty)
        XCTAssertTrue(repository.recents.isEmpty)
        XCTAssertEqual(repository.removedIDs, [Location.preview.id])
    }

    func testClearRecentLocationsUpdatesListAndRepository() async {
        let repository = StubLocationRepository()
        repository.recents = [.preview]
        let model = makeModel(repository: repository)
        await model.loadRecentLocations()

        await model.clearRecentLocations()

        XCTAssertTrue(model.recentLocations.isEmpty)
        XCTAssertTrue(repository.recents.isEmpty)
    }

    func testLoadRecentLocationsFallsBackToEmptyOnError() async {
        let repository = StubLocationRepository()
        repository.error = APIError.invalidResponse
        let model = makeModel(repository: repository)

        await model.loadRecentLocations()

        XCTAssertTrue(model.recentLocations.isEmpty)
    }

    // MARK: - Helpers

    private func makeModel(repository: StubLocationRepository) -> LocationSearchModel {
        LocationSearchModel(repository: repository)
    }
}
