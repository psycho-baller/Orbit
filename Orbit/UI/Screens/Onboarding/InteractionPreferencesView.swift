//
//  InteractionPreferencesView.swift
//  Orbit
//
//  Created by Ubaid Niaz on 2024-11-07.
//

import SwiftUI

struct InteractionPreferencesView: View {
    @ObservedObject var onboardingVM: OnboardingViewModel
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.colorScheme) var colorScheme  // Detect system color scheme
    @StateObject private var viewModel = InteractionPreferencesViewModel()

    var body: some View {
        ZStack {
            // Background Color for the entire screen
            ColorPalette.background(for: colorScheme)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 10) {
                    Text("Interaction Preferences")
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
                        // Loop through the first 2 questions and display them with a dynamic tag layout
                        ForEach(viewModel.questions.prefix(2)) { question in
                            VStack(alignment: .leading, spacing: 12) {
                                Text(question.text)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(
                                        ColorPalette.secondaryText(
                                            for: colorScheme))

                                FlowLayout(items: question.options) {
                                    option in
                                    self.tagView(for: option, in: question)
                                }
                            }
                        }

                        // **Preferred Age Range Selection**
                        VStack(alignment: .leading, spacing: 12) {
                            Text(
                                "What is your preferred age range for interactions?"
                            )
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(
                                ColorPalette.secondaryText(for: colorScheme))

                            // Display selected age range
                            HStack {
                                Text("\(viewModel.preferredMinAge ?? 18)")
                                Spacer()
                                Text("\(viewModel.preferredMaxAge ?? 60)")
                            }
                            .font(.subheadline)
                            .foregroundColor(
                                ColorPalette.text(for: colorScheme))

                            // Age range selection slider
                            //                            RangeSliderView(
                            //                                selectedMin: Binding(
                            //                                    get: { viewModel.preferredMinAge ?? 18 },
                            //                                    set: { viewModel.preferredMinAge = $0 }
                            //                                ),
                            //                                selectedMax: Binding(
                            //                                    get: { viewModel.preferredMaxAge ?? 60 },
                            //                                    set: { viewModel.preferredMaxAge = $0 }
                            //                                ),
                            //                                minValue: 18,
                            //                                maxValue: 60
                            //                            )
                        }

                        // **Preferred Gender Selection**
                        VStack(alignment: .leading, spacing: 12) {
                            Text(
                                "What is your preferred gender for interactions?"
                            )
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(
                                ColorPalette.secondaryText(for: colorScheme))

                            FlowLayout(items: UserGender.allCases) {
                                gender in
                                Text(gender.rawValue.capitalized)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        viewModel.preferredGender.contains(
                                            gender)
                                            ? ColorPalette.accent(
                                                for: colorScheme)
                                            : ColorPalette.lightGray(
                                                for: colorScheme)
                                    )
                                    .foregroundColor(
                                        viewModel.preferredGender.contains(
                                            gender)
                                            ? .white
                                            : ColorPalette.text(
                                                for: colorScheme)
                                    )
                                    .cornerRadius(10)
                                    .onTapGesture {
                                        if viewModel.preferredGender.contains(
                                            gender)
                                        {
                                            viewModel.preferredGender.removeAll
                                            { $0 == gender }
                                        } else {
                                            viewModel.preferredGender.append(
                                                gender)
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
                        let selectedAnswers =
                            viewModel.getInteractionPreferences()
                        onboardingVM.navigationPath.append(
                            OnboardingViewModel.OnboardingStep.friendshipValues)
                        Task {
                            await userVM.saveOnboardingData(
                                interactionPreferences: selectedAnswers)
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
        let hasSelectedQuestions = viewModel.questions.prefix(2).allSatisfy {
            question in
            question.options.contains { $0.isSelected }
        }

        let hasValidAgeRange =
            viewModel.preferredMinAge != nil && viewModel.preferredMaxAge != nil
        let hasSelectedGenders = !viewModel.preferredGender.isEmpty

        return hasSelectedQuestions && hasValidAgeRange && hasSelectedGenders
    }

    private func tagView(for option: QuestionOption, in question: Question)
        -> some View
    {
        Text(option.title)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                option.isSelected
                    ? ColorPalette.accent(for: colorScheme)
                    : ColorPalette.lightGray(for: colorScheme)
            )
            .foregroundColor(
                option.isSelected
                    ? .white
                    : ColorPalette.text(for: colorScheme)
            )
            .cornerRadius(10)
            .onTapGesture {
                viewModel.toggleSelection(for: option, in: question)
            }
    }
}

#Preview {
    InteractionPreferencesView(onboardingVM: OnboardingViewModel())
        .environmentObject(UserViewModel())
}
