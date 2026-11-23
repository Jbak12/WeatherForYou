//
//  LocationListRow.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 23/11/2026.
//

import SwiftUI

/// A selectable location card with list-row styling.
struct LocationListRow: View {
    let model: LocationRowModel
    let accessibilityScope: String
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack {
                LocationRow(model: model)

                Image(systemName: "chevron.forward")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("\(accessibilityScope).row.\(model.id)")
        .listRowBackground(Color.backgroundPrimary)
        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
        .listRowSeparator(.hidden)
    }
}

#if DEBUG
#Preview("Location in a list") {
    List {
        LocationListRow(model: LocationRowModel(location: .preview), accessibilityScope: "search.results", onSelect: {})
    }
    .listStyle(.plain)
    .scrollContentBackground(.hidden)
    .background(.backgroundPrimary)
}
#endif
