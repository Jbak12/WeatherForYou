# WeatherForYou Project

WeatherForYou is an iOS app for looking up a city's current weather and forecast using [Open-Meteo](https://open-meteo.com/).

## Features

- **City search:** Type at least two characters to find a location. Names can include accented letters, spaces, and hyphens, as in “Nowy Sącz” or “Bielsko-Biała”. Results show coordinates and, when available, the region and country to help distinguish places with the same name.
- **Current conditions:** See the temperature, what it feels like, today's high and low, humidity, wind, gusts, and precipitation when available.
- **Hourly and daily forecasts:** Scroll through up to 24 hourly entries starting with the current hour, or check the seven-day outlook for highs, lows, and the chance of precipitation. Forecast times and the “Today” label use the city's time zone.
- **Recent locations:** Clear the search field to revisit up to 10 cities whose forecasts loaded successfully. History is saved on the device. Swipe to remove one city or tap **Clear** to remove them all.

## Localization

App copy uses semantic keys in `WeatherForYou/Resources/Localizable.xcstrings`. English is
the only supported language. Add translations in the catalog, and keep complete
sentences together when they contain placeholders. The launch storyboard uses
`WeatherForYou/en.lproj/LaunchScreen.strings` for its tagline. Place names and other API data
are displayed as supplied by the service.

## Architecture

The app source under `WeatherForYou/` is organized by feature within one Xcode target:

- `App/` owns the entry point, root navigation, and live dependency wiring.
- `Features/Locations/` owns Search and Recents, including geocoding and the
  recent-location store.
- `Features/Forecast/` owns forecast loading, normalization, and presentation.
- `Shared/` contains the HTTP client, app database setup, and types used by
  multiple features, such as `Coordinates`.

Each feature keeps its data access code in `Data/` and its preview fixtures
alongside the feature. Unit tests follow the same Locations, Forecast, and
Shared grouping.

Data flows in one direction:

```
Views → View Models → Repositories → Services (networking)
                                   → Stores (local persistence)
```

- **Views** render state and forward user actions.
- **View models** (`ObservableObject` + `@Published`) own screen state.
- **Repositories** (`LocationRepository`, `ForecastRepository`) are the
  app-facing data contract. They compose the data sources and own policies such
  as caching or merging.
- **Services** (`GeocodingService`, `ForecastService`) perform the HTTP work.
- **Stores** (`RecentLocationStore`) own local persistence.

View models depend only on repository protocols. The app supplies the live
location repository, and the forecast screen uses the live forecast repository
unless a caller injects one. Tests and previews can substitute stubs. For
example, `DefaultLocationRepository` combines
`GeocodingService` for search with `RecentLocationStore` for history, and view
models never see either type.

### Models

- **DTOs** (`LocationDto`) mirror the API payload and are used by services,
  repositories, and stores.
- **Presentation models** (`LocationRowModel`) expose only what a view renders,
  with strings already formatted. View models build them, so views stay free of
  formatting logic.

### Forecast data flow

`ForecastDto` mirrors Open-Meteo's JSON. The forecast service converts it
to `Forecast`, a typed model with dates, weather codes, and units. The repository
returns that model without display formatting.

`ForecastViewModel` uses `ForecastPresentationMapper` to produce
`ForecastDetailsModel` and its display-ready sections. The mapper formats values
for the selected locale and forecast time zone, and selects up to 24 hourly
entries starting with the current hour when available. The views only render
the resulting models.

## Persistence (GRDB)

Recents are stored in SQLite through [GRDB](https://github.com/groue/GRDB.swift).
The database lives at:

```
Application Support/WeatherForYou/weather.sqlite
```

`AppDatabase` opens it once, runs migrations, and exposes a `DatabaseWriter`.
If the file cannot be opened, the app keeps working with an empty recent list
instead of crashing.

**Behavior**

- A city is saved when its forecast screen finishes loading successfully.
- Re-viewing a city moves it to the top instead of adding a duplicate.
- The search screen shows the 10 most recent cities when the search field is
  empty. Swipe a row to remove it, or use **Clear** in the section header.
- Recents are reloaded when you navigate back from a forecast.

**Schema**

`recent_location` stores the location ID, name, coordinates, timezone, region,
and country, plus `last_viewed_at` for ordering. The v2 migration removes unused
API fields without discarding existing history.

**Layering**

View models depend on `LocationRepository`, not on GRDB or `RecentLocationStore`.
`DefaultLocationRepository` composes the geocoding service with the store, and
`GRDBRecentLocationStore` handles Recents queries and writes; `AppDatabase`
opens and migrates the shared database.
`AppDatabase.inMemory()` lets tests and previews run against a throwaway
database.

To reset history, delete the app from the simulator/device (or the database
file above).

## Static URL macro

The app uses a local Swift macro package, [`StaticURL`](StaticURL), to validate
URL literals at compile time:

```swift
import StaticURL

private static let baseURL = #staticURL("https://api.open-meteo.com")
```

`#staticURL` rejects non-literal arguments and invalid URLs while compiling, so a
bad URL fails the build instead of crashing at runtime.

> Keep `StaticURL/` at the repository root. It must **not** live inside
> `WeatherForYou/`, because that folder is an Xcode file-system synchronized
> group — the macro sources would be compiled into the iOS app target and fail
> with `No such module 'SwiftCompilerPlugin'`.

## Building with Xcode 26 / Swift 6.2

Xcode 26 enables **SwiftPM prebuilt swift-syntax binaries** by default. They can
fail the macro build with:

> Module 'SwiftCompilerPlugin' was created for incompatible target aarch64-apple-macosx10.15

Disable prebuilts so swift-syntax builds from source:

```bash
defaults write com.apple.dt.Xcode IDEPackageEnablePrebuilts -bool NO
```

Then:

1. Quit and reopen Xcode (the setting is read at launch).
2. Select the **WeatherForYou** scheme — not the `StaticURL` package scheme.
3. Product → **Clean Build Folder**.
4. Build for an iOS Simulator.

The first build compiles swift-syntax from source and is slower; later builds are
cached.

For command-line builds, pass the flag explicitly (xcodebuild does not read the
Xcode default):

```bash
xcodebuild -project WeatherForYou.xcodeproj -scheme WeatherForYou \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -IDEPackageEnablePrebuilts=NO build
```

To re-enable prebuilts later:

```bash
defaults delete com.apple.dt.Xcode IDEPackageEnablePrebuilts
```
