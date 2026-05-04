//
//  Color+Hex.swift
//  TrekFit
//
//  Extension: Color + Hex initialiser
//  Allows any SwiftUI Color to be created from a plain hex string.
//
//  Usage:
//    Color(hex: "FF8D28")       // brand orange
//    Color(hex: "3C3C43")       // secondary label
//    Color(hex: "E6E6E6")       // separator
//

import SwiftUI

extension Color {

    /// Creates a SwiftUI `Color` from a 6-character RGB hex string (case-insensitive).
    /// - Parameter hex: A 6-digit hex string, e.g. `"FF8D28"`. The `#` prefix is optional.
    init(hex: String) {
        // Strip optional leading "#" and whitespace
        let cleaned = hex.trimmingCharacters(in: .alphanumerics.inverted)

        // Parse the hex string into a single UInt64 integer
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)

        // Extract individual 8-bit RGB channels from the packed integer
        let r = Double((value >> 16) & 0xFF) / 255.0   // bits 23-16
        let g = Double((value >>  8) & 0xFF) / 255.0   // bits 15-8
        let b = Double( value        & 0xFF) / 255.0   // bits 7-0

        self.init(red: r, green: g, blue: b)
    }
}
