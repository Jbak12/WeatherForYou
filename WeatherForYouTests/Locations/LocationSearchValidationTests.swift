import XCTest
@testable import WeatherForYou

@MainActor
final class LocationSearchValidationTests: XCTestCase {
    func testAcceptsPolishLettersSpacesAndHyphens() async {
        let model = LocationSearchViewModel(repository: StubLocationRepository())

        for name in ["Bielsko-Biała", "Nowy Sącz", "Łódź", "Ło\u{0301}dz\u{0301}"] {
            model.query = name
            XCTAssertEqual(model.query, name)
        }
    }

    func testPastedInputSendsOnlyAllowedCharacters() async {
        let repository = StubLocationRepository()
        let model = LocationSearchViewModel(repository: repository, debounce: .zero)

        model.query = "Łódź123٢!🙂\t\n"
        await model.search()

        XCTAssertEqual(model.query, "Łódź")
        XCTAssertEqual(repository.searchedQueries, ["Łódź"])
    }

    func testInputWithOnlyDisallowedCharactersDoesNotSearch() async {
        let repository = StubLocationRepository()
        let model = LocationSearchViewModel(repository: repository, debounce: .zero)

        model.query = "123!@🙂\n"
        await model.search()

        XCTAssertTrue(model.query.isEmpty)
        XCTAssertEqual(model.state, .idle)
        XCTAssertTrue(repository.searchedQueries.isEmpty)
    }
}
