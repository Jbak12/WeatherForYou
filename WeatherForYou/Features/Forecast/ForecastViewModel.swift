//
//  ForecastViewModel.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import Foundation
import Combine

/// Drives the forecast screen for a single location.
@MainActor
final class ForecastViewModel: ObservableObject {
    enum State {
        case idle
        case loading
        case loaded(ForecastDetailsModel)
        case failed(String)
    }

    @Published private(set) var state: State = .idle
    private let coordinates: Coordinates
    private let name: String
    private let subtitle: String?
    private let repository: ForecastRepository
    private let onForecastLoaded: @MainActor () async -> Void

    init(
        coordinates: Coordinates,
        name: String,
        subtitle: String?,
        repository: ForecastRepository,
        onForecastLoaded: @escaping @MainActor () async -> Void = {}
    ) {
        self.coordinates = coordinates
        self.name = name
        self.subtitle = subtitle
        self.repository = repository
        self.onForecastLoaded = onForecastLoaded
    }

    func load() async {
        if case .loading = state { return }

        state = .loading

        do {
            let forecast = try await repository.forecast(at: coordinates)
            let mapper = ForecastPresentationMapper(locale: .current, now: .now)
            state = .loaded(mapper.map(forecast, name: name, subtitle: subtitle))
            await onForecastLoaded()
        } catch is CancellationError {
            return
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
