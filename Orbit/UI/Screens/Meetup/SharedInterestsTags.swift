//
//  SharedInterestsTags.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-10-07.
//  This view displays a list of interest tags without horizontal scrolling. It only shows as many tags as can fit within the available width.

import SwiftUI

struct TagWidthPreferenceKey: PreferenceKey {
    static var defaultValue: [String: CGFloat] = [:]
    static func reduce(
        value: inout [String: CGFloat], nextValue: () -> [String: CGFloat]
    ) {
        value.merge(nextValue(), uniquingKeysWith: { _, new in new })
    }
}

struct SharedInterestsTags: View {
    var interests: [String]
    @Environment(\.colorScheme) var colorScheme
    @State private var tagWidths: [String: CGFloat] = [:]

    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width
            let displayedInterests = computeDisplayedInterests(
                availableWidth: availableWidth)

            HStack(spacing: 10) {
                ForEach(displayedInterests, id: \.self) { interest in
                    Text(interest)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(LightGrayOrMaterial())
                        .foregroundColor(
                            ColorPalette.secondaryText(for: colorScheme)
                        )
                        .clipShape(Capsule())
                        .fixedSize(horizontal: true, vertical: false)
                        // Measure the tag's width and store it in state
                        .background(
                            GeometryReader { geo in
                                Color.clear
                                    //                                    .onAppear {
                                    //                                        tagWidths[interest] = geo.size.width
                                    //                                    }
                                    .preference(
                                        key: TagWidthPreferenceKey.self,
                                        value: [interest: geo.size.width])
                            }
                        )
                }
            }
            .onPreferenceChange(TagWidthPreferenceKey.self) { widths in
                tagWidths = widths
            }.frame(width: availableWidth, alignment: .leading)
            .clipped()
        }
        // Let the view size itself vertically as needed
    }

    // This function computes how many tags can fit in the available width.
    private func computeDisplayedInterests(availableWidth: CGFloat) -> [String]
    {
        var totalWidth: CGFloat = 0
        var displayed: [String] = []

        // Iterate over interests in order
        for interest in interests {
            // Use the measured width if available, otherwise a default estimate
            let width = tagWidths[interest] ?? 60
            // Add spacing of 10 for each tag (except possibly the first one)
            if totalWidth + width + (displayed.isEmpty ? 0 : 10)
                <= availableWidth
            {
                displayed.append(interest)
                totalWidth += width + (displayed.count == 1 ? 0 : 10)
            } else {
                break
            }
        }
        return displayed
    }
}

// Preview for testing
struct SharedInterestsTags_Previews: PreviewProvider {
    static var previews: some View {
        SharedInterestsTags(interests: [
            "Music", "Art", "Sports", "Tech", "Travel",
        ])
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
