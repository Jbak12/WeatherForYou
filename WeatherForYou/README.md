# WeatherForYou Project

## Architecture

Data flows in one direction:

```
Views → View Models → Repositories → Services (networking)
```

- **Views** render state and forward user actions.
- **View models** (`ObservableObject` + `@Published`) own screen state.
- **Repositories** (`LocationRepository`, `ForecastRepository`) define the data
  the app needs, independent of where it comes from.
- **Services** (`GeocodingService`, `ForecastService`) perform the HTTP work.

View models depend only on repository protocols and default to the live
implementations (`DefaultLocationRepository`, `DefaultForecastRepository`).
Tests and previews inject stubs, so nothing in the UI layer changes when a new
data source is added. The repository is the seam for a future SQLite/GRDB
cache: persistence will be added inside the default repositories, not in the
views or view models.

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
