//
//  Array+SafeSubscript.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import Foundation

extension Array {
    /// Returns the element at `index`, or `nil` when the index is out of bounds.
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
