//
//  InterestsHorizontalTags.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-10-07.
//  Copyright © 2024 CPSC 575. All rights reserved.
//
import SwiftUI

struct InterestsHorizontalTags: View {
    var interests: [String]
    var onTapInterest: (String) -> Void
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.colorScheme) var colorScheme  // Access color scheme from environment

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(interests, id: \.self) { interest in
                    Text(interest)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            userVM.selectedInterests.contains(interest)
                                ? ColorPalette.accent(for: colorScheme)  // Selected interest background
                                : ColorPalette.lightGray(for: colorScheme)
                                     // Non-selected interest background
                        )
                        .foregroundColor(
                            userVM.selectedInterests.contains(interest)
                                ? ColorPalette.text(for: colorScheme)  // Text color for selected
                                : ColorPalette.secondaryText(for: colorScheme)  // Text color for non-selected
                        )
                        .clipShape(Capsule())
                        .shadow(
                            color: userVM.selectedInterests.contains(interest)
                                ? ColorPalette.accent(for: colorScheme).opacity(
                                    0.5) : .clear, radius: 5, x: 0,
                            y: 4
                        )
                        .onTapGesture {
                            withAnimation(.spring()) {
                                onTapInterest(interest)
                            }
                        }
                        .scaleEffect(
                            userVM.selectedInterests.contains(interest)
                                ? 1.1 : 1.0
                        )  // Scale effect for selected interest
                        .animation(
                            .spring(),
                            value: userVM.selectedInterests.contains(interest))  // Spring animation
                }
            }
            .padding()
        }
    }
}
