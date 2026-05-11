import SwiftUI

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
            (a, r, g, b) = (255, 0, 0, 0)
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

// MARK: - Theme Colors
extension Color {
    static let theme = ThemeColors()
}

struct ThemeColors {
    let background = Color("Background")
    let surface = Color("Surface")
    let primary = Color(hex: "5E5CE6")
    let primaryLight = Color(hex: "7B78FF")
    let accent = Color(hex: "FF6B35")
    let accentLight = Color(hex: "FF8A5C")
    let success = Color(hex: "34C759")
    let warning = Color(hex: "FF9F0A")
    let error = Color(hex: "FF453A")
    let textPrimary = Color("TextPrimary")
    let textSecondary = Color(hex: "8E8E93")
    
    // Gradient presets
    var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "5E5CE6"), Color(hex: "7B78FF")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var accentGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "FF6B35"), Color(hex: "FF8A5C")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var surfaceGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "1C1C2E"), Color(hex: "2C2C3E")],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
