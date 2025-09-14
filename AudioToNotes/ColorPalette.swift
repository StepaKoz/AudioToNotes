import SwiftUI

struct ColorPalette {
    static let primary    = Color(hex: "#D2B48C")
    static let secondary  = Color(hex: "#2C2C2C")
    static let accent     = Color(hex: "#A0522D")
    static let accent2    = Color(hex: "#CD853F")
    static let accent3    = Color(hex: "#F5F5DC")
    
    static let noteColors: [Color] = [
        Color(hex: "#D2B48C"),
        Color(hex: "#CD853F"),
        Color(hex: "#A0522D"),
        Color(hex: "#8B4513"),
        Color(hex: "#F5DEB3")
    ]
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

