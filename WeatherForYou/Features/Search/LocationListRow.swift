//
//  LocationListRow.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 23/11/2026.
//

import SwiftUI

/// A location row wrapped in navigation and list-row styling.
///
/// The list-row modifiers must be applied to the `NavigationLink` itself,
/// because it is the actual list row. Applying them inside the label (in
/// `LocationRow`) leaves the cell's default background and separator visible.
struct LocationListRow: View {
    let model: LocationRowModel

    var body: some View {
        NavigationLink(value: model.location) {
            LocationRow(model: model)
        }
        .listRowBackground(Color.backgroundPrimary)
        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
        .listRowSeparator(.hidden)
    }
}
