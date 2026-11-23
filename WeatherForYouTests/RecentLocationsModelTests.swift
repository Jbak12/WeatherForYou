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
        let store = StubRecentLocationStore()
        store.locations = [.preview]
        let model = makeModel(store: store)

        await model.loadRecentLocations()

        XCTAssertEqual(model.recentLocations, [.preview])
    }

    func testRemoveRecentLocationUpdatesListAndStore() async {
        let store = StubRecentLocationStore()
        store.locations = [.preview]
        let model = makeModel(store: store)
        await model.loadRecentLocations()

        await model.removeRecentLocation(.preview)

        XCTAssertTrue(model.recentLocations.isEmpty)
        XCTAssertTrue(store.locations.isEmpty)
    }

    func testClearRecentLocationsUpdatesListAndStore() async {
        let store = StubRecentLocationStore()
        store.locations = [.preview]
        let model = makeModel(store: store)
        await model.loadRecentLocations()

        await model.clearRecentLocations()

        XCTAssertTrue(model.recentLocations.isEmpty)
        XCTAssertTrue(store.locations.isEmpty)
    }

    func testLoadRecentLocationsFallsBackToEmptyOnError() async {
        let store = StubRecentLocationStore()
        store.error = APIError.invalidResponse
        let model = makeModel(store: store)

        await model.loadRecentLocations()

        XCTAssertTrue(model.recentLocations.isEmpty)
    }

    // MARK: - Helpers

    private func makeModel(store: StubRecentLocationStore) -> LocationSearchModel {
        LocationSearchModel(
            repository: PreviewLocationRepository(),
            recentStore: store
        )
    }
}
