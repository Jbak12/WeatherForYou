import SwiftUI

struct WeatherIcon: View {
    let model: WeatherIconModel
    let accessibilityID: String
    var size: CGFloat = 28

    var body: some View {
        Image(model.image)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .foregroundStyle(.iconPrimary)
            .accessibilityLabel(Text(model.accessibilityLabel))
            .accessibilityIdentifier(accessibilityID)
    }
}

#Preview("Day, night, and rain") {
    let mapper = ForecastPresentationMapper(locale: .current, now: .now)
    HStack(spacing: 16) {
        WeatherIcon(model: mapper.icon(for: .clearSky, isDay: true), accessibilityID: "preview.weather.day", size: 40)
        WeatherIcon(model: mapper.icon(for: .clearSky, isDay: false), accessibilityID: "preview.weather.night", size: 40)
        WeatherIcon(model: mapper.icon(for: .heavyRain, isDay: true), accessibilityID: "preview.weather.rain", size: 40)
    }
    .padding()
    .background(.backgroundPrimary)
}
