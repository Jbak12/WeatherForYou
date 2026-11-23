import SwiftUI

struct WeatherIcon: View {
    let model: WeatherIconModel
    var size: CGFloat = 28

    var body: some View {
        Image(model.image)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .foregroundStyle(.iconPrimary)
            .accessibilityLabel(Text(model.accessibilityLabel))
    }
}
