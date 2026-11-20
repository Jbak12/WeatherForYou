//
//  ContentView.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 18/11/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .task {
            
            try! await Task.sleep(for: .seconds(10))
            let ziomek = await GeolocatingApi.fetchLocationDummy()
            print(ziomek)
        }
    }
}

#Preview {
    ContentView()
}
