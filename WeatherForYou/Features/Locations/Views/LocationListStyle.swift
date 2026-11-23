import SwiftUI

extension View {
    func locationListStyle() -> some View {
        listStyle(.plain)
            .scrollContentBackground(.hidden)
    }
}
