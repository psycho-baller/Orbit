//
//  FriendshipValuesView.swift
//  Orbit
//
//  Created by Ubaid Niaz on 2024-11-07.
//

import SwiftUI

struct FriendshipValuesView: View {
    @ObservedObject var onboardingVM: OnboardingViewModel
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.colorScheme) var colorScheme  // Detect system color scheme
    @StateObject private var viewModel = FriendshipValuesViewModel()

    // Define the grid layout for three columns
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var body: some View {
        ZStack {
            // Background Color for the entire screen
            ColorPalette.background(for: colorScheme)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 10) {
                    Text("Friendship Values and Qualities")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(ColorPalette.text(for: colorScheme))
                        .padding(.horizontal)
                        .padding(.top, 15)
                        .padding(.bottom, 20)
                }
                .background(ColorPalette.background(for: colorScheme))  // Keep header static

                // Scrollable Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        // Loop through each question
                        ForEach(viewModel.questions) { question in
                            VStack(alignment: .leading, spacing: 12) {
                                Text(question.text)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(
                                        ColorPalette.secondaryText(
                                            for: colorScheme))

                                // Use LazyVGrid for a multi-column layout with three columns
                                LazyVGrid(columns: columns, spacing: 12) {
                                    ForEach(question.options) { option in
                                        Text(option.title)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .frame(
                                                maxWidth: .infinity,
                                                alignment: .center
                                            )
                                            .background(
                                                option.isSelected
                                                    ? ColorPalette.accent(
                                                        for: colorScheme)
                                                    : ColorPalette.lightGray(
                                                        for: colorScheme)
                                            )
                                            .foregroundColor(
                                                option.isSelected
                                                    ? .white
                                                    : ColorPalette.text(
                                                        for: colorScheme)
                                            )
                                            .cornerRadius(10)
                                            .onTapGesture {
                                                viewModel.toggleSelection(
                                                    for: option, in: question)
                                            }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .background(ColorPalette.background(for: colorScheme))  // Fix scrolling issue
                }
                .background(ColorPalette.background(for: colorScheme))  // Fix scrolling issue

                // Always visible footer button
                VStack {
                    Button(action: {
                        let selectedAnswers = viewModel.getFriendshipValues()
                        onboardingVM.navigationPath.append(
                            OnboardingViewModel.OnboardingStep
                                .userInfo)
                        Task {
                            await userVM.saveOnboardingData(
                                friendshipValues: selectedAnswers.friendshipValues,
                                friendshipQualities: selectedAnswers.friendshipQualities
                            )
                        }
                    }) {
                        Text("Next")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                canProceed()
                                    ? ColorPalette.accent(for: colorScheme)
                                    : ColorPalette.lightGray(for: colorScheme)
                            )
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(!canProceed())
                    .padding(.horizontal)
                }
                .padding(.bottom, 20)  // Ensure some spacing at the bottom
                .background(ColorPalette.background(for: colorScheme))  // Add background color to footer
            }
        }
        .onAppear {
            // Update the ViewModel with the correct user data
            viewModel.loadQuestions(with: userVM.currentUser)
        }
    }

    private func canProceed() -> Bool {
        // Ensure at least one option is selected for each question
        return viewModel.questions.allSatisfy { question in
            question.options.contains { $0.isSelected }
        }
    }
}

struct FriendshipValuesView_Previews: PreviewProvider {
    static var previews: some View {
        FriendshipValuesView(onboardingVM: OnboardingViewModel())
            .environmentObject(UserViewModel())
    }
}
