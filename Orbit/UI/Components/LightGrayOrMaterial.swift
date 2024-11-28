//
//  LightGrayOrMaterial.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-11-27.
//

import SwiftUI

struct LightGrayOrMaterial: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Group {
            if colorScheme == .dark {
                Color.clear.background(.ultraThinMaterial)  // Material for dark mode
            } else {
                ColorPalette.lightGray(for: colorScheme)  // Light gray for light mode
            }
        }
    }
}
