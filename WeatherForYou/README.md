# WeatherForYou Project

## Architecture

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

View models depend only on repository protocols and default to the live
implementations (`DefaultLocationRepository`, `DefaultForecastRepository`).
Tests and previews inject stubs, so nothing in the UI layer changes when a new
data source is added. For example, `DefaultLocationRepository` combines
`GeocodingService` for search with `RecentLocationStore` for history, and view
models never see either type.

### Models

- **DTOs** (`LocationDto`) mirror the API payload and are used by services,
  repositories, and stores.
- **Presentation models** (`LocationRowModel`) expose only what a view renders,
  with strings already formatted. View models build them, so views stay free of
  formatting logic.

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

`recent_location` stores the location's API fields plus `last_viewed_at`, which
drives ordering. `postcodes` is stored as a JSON array in a text column.

**Layering**

View models depend on `LocationRepository`, not on GRDB or `RecentLocationStore`.
`DefaultLocationRepository` composes the geocoding service with the store, and
`GRDBRecentLocationStore` is the only type that imports GRDB for persistence.
`AppDatabase.inMemory()` lets tests and previews run against a throwaway
database.

To reset history, delete the app from the simulator/device (or the database
file above).

## Static URL macro

The app uses a local Swift macro package, [`StaticURL`](../StaticURL), to validate
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
