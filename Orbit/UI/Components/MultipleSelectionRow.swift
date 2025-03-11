//
//  MultipleSelectionRow.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-02-25.
//

import SwiftUI

struct MultipleSelectionRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            }
            .padding(.vertical, 8)
        }
        .accentColor(ColorPalette.accent(for: colorScheme))
    }
}
#Preview {
    MultipleSelectionRow(title: "Test", isSelected: true, action: { })
}