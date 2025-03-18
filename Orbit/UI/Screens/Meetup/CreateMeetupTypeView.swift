//
//  CreateMeetupTypeView.swift
//  Orbit
//
//  Created by Nathaniel D'Orazio on 2025-02-24.
//

import SwiftUI

struct CreateMeetupTypeView: View {
    @EnvironmentObject var meetupRequestVM: MeetupRequestViewModel
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    @State private var selectedType: MeetupType? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                ColorPalette.background(for: colorScheme)
                    .ignoresSafeArea()

                VStack {
                    ScrollView {
                        VStack(spacing: 24) {
                            Text("What would you like to do?")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            // Meetup Type Buttons
                            VStack(spacing: 12) {
                                MeetupTypeButton(
                                    title: "Get Coffee",
                                    icon: "cup.and.saucer.fill",
                                    isSelected: selectedType == .coffee
                                ) {
                                    selectedType = .coffee
                                }

                                MeetupTypeButton(
                                    title: "Have a meal",
                                    icon: "fork.knife",
                                    isSelected: selectedType == .meal
                                ) {
                                    selectedType = .meal
                                }

                                MeetupTypeButton(
                                    title: "Sports/Workout",
                                    icon: "figure.run",
                                    isSelected: selectedType == .indoorActivity
                                ) {
                                    selectedType = .indoorActivity
                                }

                                MeetupTypeButton(
                                    title: "Outdoor activity",
                                    icon: "figure.hiking",
                                    isSelected: selectedType == .outdoorActivity
                                ) {
                                    selectedType = .outdoorActivity
                                }

                                MeetupTypeButton(
                                    title: "Other",
                                    icon: "ellipsis.circle.fill",
                                    isSelected: selectedType == .other
                                ) {
                                    selectedType = .other
                                }
                            }
                            .padding()
                        }
                        .padding()
                    }

                    // Footer with Next button
                    VStack {
                        NavigationLink(
                            destination: {
                                if let type = selectedType {
                                    CreateMeetupDetailsView(selectedType: type)
                                }
                            },
                            label: {
                                Text("Next")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        selectedType != nil
                                            ? ColorPalette.accent(
                                                for: colorScheme)
                                            : ColorPalette.lightGray(
                                                for: colorScheme)
                                    )
                                    .cornerRadius(12)
                            }
                        )
                        .disabled(selectedType == nil)
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 20)
                    .background(ColorPalette.background(for: colorScheme))
                }
            }
        }
    }
}

struct MeetupTypeButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.body)
                Spacer()
            }
            .foregroundColor(
                isSelected ? .white : ColorPalette.text(for: colorScheme)
            )
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                isSelected
                    ? Color.accentColor
                    : ColorPalette.lightGray(for: colorScheme)
            )
            .cornerRadius(12)
        }
        .accentColor(ColorPalette.accent(for: colorScheme))
    }
}

#if DEBUG
    #Preview {
        @Previewable @Environment(\.colorScheme) var colorScheme

        CreateMeetupTypeView()
            .environmentObject(MeetupRequestViewModel.mock())
            .environmentObject(UserViewModel.mock())
            .accentColor(ColorPalette.accent(for: colorScheme))
    }
#endif
