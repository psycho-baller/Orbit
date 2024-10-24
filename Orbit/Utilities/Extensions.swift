//
//  Extensions.swift
//  Appwrite Jobs
//
//  Created by Damodar Lohani on 15/10/2021.
//

import SwiftUI

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
