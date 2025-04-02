//
//  InterestGrid.swift
//  Orbit
//
//  Created by Nathaniel D'Orazio on 2025-03-25.
//

import SwiftUI

struct InterestGrid: View {
    let title: String
    let items: [String]
    let selectedItems: Set<String>
    let onItemTap: (String) -> Void
    @Environment(\.colorScheme) var colorScheme
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with expand/collapse
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack {
                    Text(title)
                        .font(.headline)
                    Spacer()
                    HStack(spacing: 8) {
                        Text("\(selectedItems.count) selected")
                            .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                            .font(.subheadline)
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                    }
                }
            }
            
            if isExpanded {
                // All interests grid
                FlowLayout(items: items) { item in
                    Button(action: { onItemTap(item) }) {
                        Text(item)
                            .lineLimit(nil) // Allows full wrapping
                            .minimumScaleFactor(0.85) // Prevents excessive shrinking
                            .multilineTextAlignment(.center)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .frame(minWidth: 80, maxWidth: .infinity) // Allows expansion
                            .background(
                                selectedItems.contains(item)
                                    ? ColorPalette.accent(for: colorScheme)
                                    : ColorPalette.lightGray(for: colorScheme).opacity(0.5)
                            )
                            .foregroundColor(
                                selectedItems.contains(item)
                                    ? .white
                                    : ColorPalette.text(for: colorScheme)
                            )
                            .cornerRadius(20)
                    }
                }
            } else if !selectedItems.isEmpty {
                // Selected interests only
                FlowLayout(items: Array(selectedItems)) { item in
                    Text(item)
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .frame(minWidth: 80)
                        .background(ColorPalette.accent(for: colorScheme).opacity(0.2))
                        .foregroundColor(ColorPalette.accent(for: colorScheme))
                        .cornerRadius(20)
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    InterestGrid(
        title: "Test Items",
        items: ["Short", "A very long interest that needs to wrap", "Medium length"],
        selectedItems: ["Short"],
        onItemTap: { _ in }
    )
}
