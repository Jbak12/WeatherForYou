import Foundation
import DeveloperToolsSupport

struct ForecastDetailsModel {
    let header: ForecastHeaderModel
    let currentConditions: CurrentConditionsModel?
    let hourly: [HourlyForecastCellModel]
    let daily: [DailyForecastRowModel]
}

struct ForecastHeaderModel {
    let name: String
    let subtitle: String?
    let current: Current?

    struct Current {
        let temperature: String
        let feelsLike: String?
        let highLow: String?
        let icon: WeatherIconModel
    }
}

struct CurrentConditionsModel {
    let humidity: String
    let wind: String
    let gusts: String
    let precipitation: String
}

struct HourlyForecastCellModel: Identifiable {
    let id: Date
    let time: String
    let temperature: String
    let precipitation: String?
    let icon: WeatherIconModel
}

struct DailyForecastRowModel: Identifiable {
    let id: Date
    let day: String
    let isToday: Bool
    let minimumTemperature: String
    let maximumTemperature: String
    let precipitation: String?
    let icon: WeatherIconModel
}

struct WeatherIconModel {
    let image: ImageResource
    let accessibilityLabel: String
}
