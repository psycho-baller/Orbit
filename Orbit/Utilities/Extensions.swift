//
//  Extensions.swift
//  Appwrite Jobs
//
//  Created by Damodar Lohani on 15/10/2021.
//

import SwiftUI
import Foundation

extension Text {
    func largeSemiBoldFont() -> Text {
        self.font(.custom("Poppins", size: 34))
            .fontWeight(.semibold)
    }
    
    func normalSemiBoldFont() -> Text {
        self.font(.custom("Poppins", size: 16))
            .fontWeight(.semibold)
    }
    
    func largeLightFont() -> Text {
        self.font(.custom("Poppins", size: 30))
            .fontWeight(.light)
    }
    
    func largeBoldFont() -> Text {
        self.font(.custom("Poppins", size: 24))
            .fontWeight(.bold)
    }
    
    
}

extension View {
    func regularFont() -> some View {
        self.font(.custom("Poppins", size: 16))
    }
    
    func cornerRadius( radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
}


extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        var a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8 * 4) & 0xF, (int >> 4) & 0xF, int & 0xF)
            (r, g, b) = (r * 17, g * 17, b * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
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
struct ColorPalette {

    static func main(for colorScheme: ColorScheme) -> Color {
        return colorScheme == .dark ? Color(hex: "#0A2342") : Color(hex: "#1E90FF")  // Dark Navy Blue for Dark Mode, Sky Blue for Light Mode
    }
    
    static func accent(for colorScheme: ColorScheme) -> Color {
        return colorScheme == .dark ? Color(hex: "#1C3A77") : Color(hex: "#4682B4")  // Lighter Navy for Dark Mode, Steel Blue for Light Mode
    }
    
    static func background(for colorScheme: ColorScheme) -> Color {
        return colorScheme == .dark ? Color(hex: "#0A1B30") : Color(hex: "#C4EBF2")  // Deep Blue Background for Dark Mode, Cyan for Light Mode
    }

    static func text(for colorScheme: ColorScheme) -> Color {
        return colorScheme == .dark ? Color(hex: "#D0EFFF") : Color(hex: "#1B3B59")  // Light Cyan Text for Dark Mode, Dark Blue Text for Light Mode
    }

    static func lightGray(for colorScheme: ColorScheme) -> Color {
        return colorScheme == .dark ? Color(hex: "#2C3E50") : Color(hex: "#B0E0E6")  // Dark Gray for Dark Mode, Powder Blue for Light Mode
    }
    
    static func secondaryText(for colorScheme: ColorScheme) -> Color {
        return colorScheme == .dark ? Color(hex: "#A2B9D2") : Color(hex: "#5F9EA0")  // Soft Blue for Dark Mode, Cadet Blue for Light Mode
    }
    
    static func button(for colorScheme: ColorScheme) -> Color {
        return colorScheme == .dark ? Color(hex: "#0077BE") : Color(hex: "#4682B4")  // Brighter Blue Buttons for both modes
    }
    static func selectedItem(for colorScheme: ColorScheme) -> Color {
        return colorScheme == .dark ? Color(hex: "#1E90FF") : Color(hex: "#00509E")
    }
}

//struct ColorPalette {
//    
//    // Main color inspired by deep space
//    static func main(for colorScheme: ColorScheme) -> Color {
//        return colorScheme == .dark ? Color(hex: "#0D1B2A") : Color(hex: "#1B263B")
//    }
//
//    // Accent color inspired by nebulae and cosmic clouds
//    static func accent(for colorScheme: ColorScheme) -> Color {
//        return colorScheme == .dark ? Color(hex: "#FF7F66") : Color(hex: "#EF476F")
//    }
//
//    // Background color inspired by starlight
//    static func background(for colorScheme: ColorScheme) -> Color {
//        return colorScheme == .dark ? Color(hex: "#09131A") : Color(hex: "#D8F3FF")
//    }
//
//    // Text color inspired by moonlight or celestial glow
//    static func text(for colorScheme: ColorScheme) -> Color {
//        return colorScheme == .dark ? Color(hex: "#EAEAEA") : Color(hex: "#1B1D23")
//    }
//
//    // Light gray inspired by star dust and clouds
//    static func lightGray(for colorScheme: ColorScheme) -> Color {
//        return colorScheme == .dark ? Color(hex: "#5A6988") : Color(hex: "#B8C1EC")
//    }
//    
//    // Secondary text inspired by distant stars and galaxies
//    static func secondaryText(for colorScheme: ColorScheme) -> Color {
//        return colorScheme == .dark ? Color(hex: "#7393B3") : Color(hex: "#375E97")
//    }
//}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
