//
//  UserInfoView.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-12-19.
//

import SwiftUI

struct UserInfoView: View {
    @ObservedObject var onboardingVM: OnboardingViewModel
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = UserInfoViewModel()
    let sixteenYearsAgo = Date().addingTimeInterval(-16 * 365 * 24 * 60 * 60)
    let oneHundredYearsAgo = Date().addingTimeInterval(
        -100 * 365 * 24 * 60 * 60)

    private var wordCount: Int {
        viewModel.bio.trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .count
    }

    private var isValidBio: Bool {
        wordCount >= 3 && wordCount <= 50
    }

    var body: some View {
        ZStack {
            // Background Color for the entire screen
            ColorPalette.background(for: colorScheme)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 10) {
                    Text("Tell Us About Yourself")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(ColorPalette.text(for: colorScheme))
                        .padding(.horizontal)
                        .padding(.top, 15)
                        .padding(.bottom, 20)
                }
                .background(ColorPalette.background(for: colorScheme))

                // Scrollable Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        // Bio Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("In 50 words or less, how would you describe yourself?")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(ColorPalette.secondaryText(for: colorScheme))

                            TextField("", text: $viewModel.bio)
                                .padding()
                                .foregroundColor(.primary)
                                .background(ColorPalette.lightGray(for: colorScheme))
                                .cornerRadius(10)

                            Text("^[\(wordCount) word](inflect: true)")
                                .font(.caption)
                                .foregroundColor(
                                    wordCount <= 50 ?
                                    ColorPalette.secondaryText(for: colorScheme) :
                                    .red
                                )
                        }

                        // Date of Birth Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your Date of Birth")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(
                                    ColorPalette.secondaryText(for: colorScheme)
                                )

                            DatePicker(
                                "Select your date of birth",
                                selection: $viewModel.dateOfBirth,
                                in: oneHundredYearsAgo...sixteenYearsAgo,
                                displayedComponents: .date
                            )
                            .labelsHidden()
                            .datePickerStyle(WheelDatePickerStyle())
                            .background(
                                ColorPalette.lightGray(for: colorScheme)
                            )
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    .background(ColorPalette.background(for: colorScheme))
                }
                .background(ColorPalette.background(for: colorScheme))

                // Always visible footer button
                VStack {
                    Button(action: {
                        onboardingVM.navigationPath.append(
                            OnboardingViewModel.OnboardingStep.personalPreferences)
                        Task {
                            await userVM.saveOnboardingData(
                                bio: viewModel.bio, dob: viewModel.dateOfBirth)
                        }
                    }) {
                        Text("Next")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                viewModel.canProceed() && isValidBio
                                    ? ColorPalette.accent(for: colorScheme)
                                    : ColorPalette.lightGray(for: colorScheme)
                            )
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(!viewModel.canProceed() || !isValidBio)
                    .padding(.horizontal)
                }
                .padding(.bottom, 20)
                .background(ColorPalette.background(for: colorScheme))
            }
        }
        .onAppear {
            viewModel.loadUserData(user: userVM.currentUser)
        }
    }
}

struct UserInfoView_Previews: PreviewProvider {
    static var previews: some View {
        UserInfoView(onboardingVM: OnboardingViewModel())
            .environmentObject(UserViewModel())
    }
}
