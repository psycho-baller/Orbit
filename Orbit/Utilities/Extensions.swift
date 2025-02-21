//
//  Extensions.swift
//  Appwrite Jobs
//
//  Created by Rami Maalouf on 15/10/2024.
//

import Appwrite
import Foundation
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
    func cornerRadius(radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(
            in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        var a: UInt64
        var r: UInt64
        var g: UInt64
        var b: UInt64
        switch hex.count {
        case 3:  // RGB (12-bit)
            (a, r, g, b) = (
                255, (int >> 8 * 4) & 0xF, (int >> 4) & 0xF, int & 0xF
            )
            (r, g, b) = (r * 17, g * 17, b * 17)
        case 6:  // RGB (24-bit)
            (a, r, g, b) = (
                255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF
            )
        case 8:  // ARGB (32-bit)
            (a, r, g, b) = (
                (int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF,
                int & 0xFF
            )
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
        return colorScheme == .dark
            ? Color(hex: "#0E1E38") : Color(hex: "#AADFE5")  // Dark Navy Blue for Dark Mode, Sky Blue for Light Mode (#E0F5F8)
    }

    static func accent(for colorScheme: ColorScheme) -> Color {
        return colorScheme == .dark
            ? Color(hex: "#00D1D7") : Color(hex: "#006F8E")  // dark: 00D1D7 or 00FFFF or 00B4D8
    }

    static func background(for colorScheme: ColorScheme) -> Color {
        return colorScheme == .dark
            ? Color(hex: "#0A0F2C") : Color(hex: "#C4EBF2")  // Deep Blue Background for Dark Mode, Cyan for Light Mode
    }

    static func text(for colorScheme: ColorScheme) -> Color {
        return colorScheme == .dark
            ? Color(hex: "#D0EFFF") : Color(hex: "#1B3B59")  // Light Cyan Text for Dark Mode, Dark Blue Text for Light Mode
    }

    static func lightGray(for colorScheme: ColorScheme) -> Color {
        return
            colorScheme == .dark
            ? Color(hex: "#2C3E50")
            : Color(hex: "#96CBD4")
    }

    static func disabled(for colorScheme: ColorScheme) -> Color {
        return colorScheme == .dark
            ? Color(hex: "#BDBDBD") : Color(hex: "#BDBDBD")
    }

    static func success(for colorScheme: ColorScheme) -> Color {
        return colorScheme == .dark
            ? Color(hex: "#00E676") : Color(hex: "#00B864")  // 4CAF50
    }

    static func warning(for colorScheme: ColorScheme) -> Color {
        return colorScheme == .dark
            ? Color(hex: "#FFCC00") : Color(hex: "#FFCC00")
    }

    static func error(for colorScheme: ColorScheme) -> Color {
        return colorScheme == .dark
            ? Color(hex: "#FF4D4D") : Color(hex: "#FF4D4D")
    }

    static func secondaryText(for colorScheme: ColorScheme) -> Color {
        return colorScheme == .dark
            ? Color(hex: "#ACC9E3") : Color(hex: "#448c89")  // Soft Blue for Dark Mode, Cadet Blue for Light Mode
    }
}

extension AppwriteModels.Document: Identifiable
where T: Identifiable, T.ID == String {
    //    public var id: String {
    //        return self.id
    //    }
}
extension AppwriteModels.Document
where T: Codable & CodableDictionaryConvertible {
    static func mock(
        data: T, collectionId: String = "default-collection",
        databaseId: String = "default-database"
    ) -> AppwriteModels.Document<T> {
        print("data: \(data)")
        print("data.toDictionary(): \(data.toDictionary())")
        var mockData: [String: Any] = [
            "$id": UUID().uuidString,
            "$collectionId": collectionId,
            "$databaseId": databaseId,
            "$createdAt": ISO8601DateFormatter().string(from: Date.distantPast),
            "$updatedAt": ISO8601DateFormatter().string(from: Date.distantPast),
            "$permissions": [],
        ]
        // 🔹 Flatten the "data" dictionary so `from(map:)` gets the correct structure
        let modelData = data.toDictionary()
        mockData.merge(modelData) { (_, new) in new }

        return AppwriteModels.Document<T>.from(map: mockData)
    }
}

protocol CodableDictionaryConvertible: Codable {
    func toDictionary() -> [String: Any]
}
extension CodableDictionaryConvertible {
    func toDictionary() -> [String: Any] {
        guard let data = try? JSONEncoder().encode(self),
            let json = try? JSONSerialization.jsonObject(with: data)
                as? [String: Any]
        else {
            return [:]  // Fallback empty dictionary if encoding fails
        }
        return json
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
        let path = UIBezierPath(
            roundedRect: rect, byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension Double {
    var degreesToRadians: Double { return self * .pi / 180 }
}
