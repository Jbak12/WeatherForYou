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

        XCTAssertEqual(model.recentLocations, [LocationRowModel(location: .preview)])
    }

    func testRemoveRecentLocationUpdatesListAndRepository() async {
        let repository = StubLocationRepository()
        repository.recents = [.preview]
        let model = makeModel(repository: repository)
        await model.loadRecentLocations()

        await model.removeRecentLocation(LocationRowModel(location: .preview))

        XCTAssertTrue(model.recentLocations.isEmpty)
        XCTAssertTrue(repository.recents.isEmpty)
        XCTAssertEqual(repository.removedIDs, [LocationDto.preview.id])
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

    func testSelectingRecentUsesRawCoordinates() async {
        let repository = StubLocationRepository()
        repository.recents = [.preview]
        let model = makeModel(repository: repository)
        await model.loadRecentLocations()

        XCTAssertEqual(
            model.selectLocation(id: LocationDto.preview.id),
            Coordinates(latitude: 52.52437, longitude: 13.41053)
        )
    }

    func testSearchSelectionRecorderSurvivesResultsBeingCleared() async {
        let repository = StubLocationRepository()
        repository.searchResults = [.preview]
        let model = LocationSearchViemodel(repository: repository, debounce: .zero)
        model.query = "Berlin"
        await model.search()

        XCTAssertEqual(
            model.selectLocation(id: LocationDto.preview.id),
            Coordinates(latitude: 52.52437, longitude: 13.41053)
        )
        let recordView = model.recentLocationRecorder()
        model.query = ""
        await model.search()
        await recordView()

        XCTAssertEqual(repository.recorded, [.preview])
    }

    // MARK: - Helpers

    private func makeModel(repository: StubLocationRepository) -> LocationSearchViemodel {
        LocationSearchViemodel(repository: repository)
    }
}
