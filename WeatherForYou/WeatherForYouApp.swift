//
//  WeatherForYouApp.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 18/11/2026.
//

import SwiftUI

@main
struct WeatherForYouApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(locationRepository: DefaultLocationRepository())
        }
    }
}
