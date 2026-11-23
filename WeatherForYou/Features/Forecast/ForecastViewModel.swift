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
        case loaded(Forecast)
        case failed(String)
    }

    @Published private(set) var state: State = .idle
    private let coordinates: Coordinates
    private let repository: ForecastRepository
    private let onLoad: @MainActor () async -> Void

    init(
        coordinates: Coordinates,
        repository: ForecastRepository,
        onLoad: @escaping @MainActor () async -> Void = {}
    ) {
        self.coordinates = coordinates
        self.repository = repository
        self.onLoad = onLoad
    }

    func load() async {
        if case .loading = state { return }

        state = .loading

        do {
            let forecast = try await repository.forecast(at: coordinates)
            state = .loaded(forecast)
            await onLoad()
        } catch is CancellationError {
            return
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
