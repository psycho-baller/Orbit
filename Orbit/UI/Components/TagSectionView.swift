//
//  TagSectionView.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-03-25.
//

import SwiftUI

struct TagSectionView: View {
    let description: String
    let otherUserTags: [String]
    let currentUserTags: [String]
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(description)
                .font(.subheadline)
                .foregroundColor(ColorPalette.secondaryText(for: colorScheme))

            // Tag list
            FlowLayout(items: otherUserTags) { tag in
                Text(tag)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        currentUserTags.contains(tag)
                            ? Color.accentColor.opacity(0.2)
                            : Color.gray.opacity(0.25)  // ColorPalette.lightGray(for: colorScheme)
                    )
                    .foregroundColor(
                        currentUserTags.contains(tag) ? .accentColor : .primary
                    )
                    .clipShape(Capsule())
            }
        }
    }
}

#Preview {
    @Previewable @Environment(\.colorScheme) var colorScheme

    TagSectionView(
        description: "What are some activities or hobbies that bring you joy?",
        otherUserTags: ["hiking", "Basketball"],
        currentUserTags: ["Basketball"]
    )
    .background(ColorPalette.background(for: colorScheme))
    .accentColor(ColorPalette.accent(for: colorScheme))
}
