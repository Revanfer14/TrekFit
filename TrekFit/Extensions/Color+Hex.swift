import SwiftUI

extension Color { //  Allows any SwiftUI Color to be created from a plain hex string, by default is not allowed
    
    /// Parameter hex: A 6-digit hex string such as `"FF8D28"`
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: .alphanumerics.inverted)
        
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        
        // 1. Bit Shift (>>): Slides the number to the right to isolate the correct Red or Green chunk.
        // 2. Masking (& 0xFF): Acts as a cutter to erase all other data, leaving exactly one color channel. (0xFF = 255)
        // 3. Division (/ 255.0): Converts the 0-255 number into a 0.0 - 1.0 percentage that SwiftUI requires.
        let r = Double((value >> 16) & 0xFF) / 255.0   // bits 23-16
        let g = Double((value >>  8) & 0xFF) / 255.0   // bits 15-8
        let b = Double( value        & 0xFF) / 255.0   // bits 7-0
        
        self.init(red: r, green: g, blue: b)
    }
}
