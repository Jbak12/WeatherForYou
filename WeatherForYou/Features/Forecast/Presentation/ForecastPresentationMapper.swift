import Foundation

/// Turns normalized weather data into the values shown on the forecast screen.
struct ForecastPresentationMapper {
    let locale: Locale
    let now: Date

    func map(_ forecast: Forecast, name: String, subtitle: String?) -> ForecastDetailsModel {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = forecast.timeZone
        let hourStart = calendar.dateInterval(of: .hour, for: now)?.start ?? now
        let today = forecast.daily.first { calendar.isDate($0.date, inSameDayAs: now) }
        let hourFormat = Date.FormatStyle(date: .omitted, time: .shortened, locale: locale, timeZone: forecast.timeZone)
        let dayFormat = Date.FormatStyle(locale: locale, timeZone: forecast.timeZone).weekday(.abbreviated)
        let units = forecast.units

        return ForecastDetailsModel(
            header: ForecastHeaderModel(name: name, subtitle: subtitle, current: forecast.current.map { current in
                ForecastHeaderModel.Current(
                    temperature: degrees(current.temperature) + units.temperature,
                    feelsLike: current.apparentTemperature.map { apparent in
                        let temperature = degrees(apparent) + units.temperature
                        return localized(LocalizedStringResource("forecast.feels_like", defaultValue: "Feels like \(temperature)"))
                    },
                    highLow: today.map { day in
                        let high = degrees(day.temperatureMax) + units.temperature
                        let low = degrees(day.temperatureMin) + units.temperature
                        return localized(LocalizedStringResource("forecast.high_low", defaultValue: "H: \(high)   L: \(low)"))
                    },
                    icon: icon(for: current.weatherCode, isDay: current.isDay)
                )
            }),
            currentConditions: forecast.current.map { conditions($0, units: units) },
            hourly: forecast.hourly.lazy.filter { $0.date >= hourStart }.prefix(24).map { entry in
                HourlyForecastCellModel(
                    id: entry.id,
                    time: entry.date.formatted(hourFormat),
                    temperature: degrees(entry.temperature) + "°",
                    precipitation: probability(entry.precipitationProbability),
                    icon: icon(for: entry.weatherCode, isDay: entry.isDay)
                )
            },
            daily: forecast.daily.map { entry in
                let isToday = calendar.isDate(entry.date, inSameDayAs: now)
                return DailyForecastRowModel(
                    id: entry.id,
                    day: isToday ? localized("forecast.daily.today") : entry.date.formatted(dayFormat),
                    isToday: isToday,
                    minimumTemperature: degrees(entry.temperatureMin) + "°",
                    maximumTemperature: degrees(entry.temperatureMax) + "°",
                    precipitation: probability(entry.precipitationProbabilityMax),
                    icon: icon(for: entry.weatherCode, isDay: true)
                )
            }
        )
    }

    private func conditions(_ current: Forecast.CurrentConditions, units: Forecast.Units) -> CurrentConditionsModel {
        let unavailable = localized("forecast.conditions.unavailable")
        let wind = current.windSpeed.map { speed in
            let speed = "\(number(speed)) \(units.windSpeed)"
            guard let direction = current.windDirection else { return speed }
            let compass = localized(WindDirection(degrees: direction).abbreviationResource)
            return localized(LocalizedStringResource("forecast.conditions.wind_value", defaultValue: "\(speed) \(compass)"))
        }

        return CurrentConditionsModel(
            humidity: current.humidity.map { number(Double($0)) + units.humidity } ?? unavailable,
            wind: wind ?? unavailable,
            gusts: current.windGusts.map { "\(number($0)) \(units.windSpeed)" } ?? unavailable,
            precipitation: current.precipitation.map { "\(number($0, digits: 1)) \(units.precipitation)" } ?? unavailable
        )
    }

    private func degrees(_ value: Double) -> String {
        let rounded = value.rounded(.toNearestOrEven)
        return number(rounded == 0 ? 0 : rounded)
    }

    private func number(_ value: Double, digits: Int = 0) -> String {
        value.formatted(.number.precision(.fractionLength(digits)).locale(locale))
    }

    private func probability(_ value: Int?) -> String? {
        guard let value, value >= 0 else { return nil }
        return (Double(value) / 100).formatted(.percent.precision(.fractionLength(0)).locale(locale))
    }

    private func localized(_ resource: LocalizedStringResource) -> String {
        var resource = resource
        resource.locale = locale
        return String(localized: resource)
    }

    func icon(for code: WeatherCode, isDay: Bool) -> WeatherIconModel {
        WeatherIconModel(image: code.imageResource(isDay: isDay), accessibilityLabel: localized(code.localizedDescription))
    }
}
