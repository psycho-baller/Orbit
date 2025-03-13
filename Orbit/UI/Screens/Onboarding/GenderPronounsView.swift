//
//  GenderPronounsView.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-02-25.
//

import SwiftUI

struct GenderPronounsView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @EnvironmentObject var userVM: UserViewModel

    @State private var selectedGender: UserGender? = nil
    @State private var selectedPronouns: Set<UserPronouns> = []

    // If UserPronouns isn’t CaseIterable, define the options manually.
    let pronounsOptions: [UserPronouns] = [.heHim, .sheHer, .theyThem] // , .other

    var body: some View {
        Form {
            Section(header: Text("Gender")) {
                ForEach(UserGender.allCases, id: \.self) { gender in
                    MultipleSelectionRow(
                        title: gender.rawValue.capitalized,
                        isSelected: selectedGender == gender
                    ) {
                        selectedGender = gender
                    }
                }
            }
            Section(header: Text("Pronouns")) {
                ForEach(pronounsOptions, id: \.self) { pronoun in
                    MultipleSelectionRow(
                        title: pronoun.rawValue,
                        isSelected: selectedPronouns.contains(pronoun)
                    ) {
                        if selectedPronouns.contains(pronoun) {
                            selectedPronouns.remove(pronoun)
                        } else {
                            selectedPronouns.insert(pronoun)
                        }
                    }
                }
            }
        }
        .navigationTitle("Gender & Pronouns")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Next") {
                    // You could save these in a separate call if desired.
                    Task {
                        // Assume that the saveOnboardingData function is extended or called elsewhere
                        // to update gender and pronouns on the user model.
                        userVM.currentUser?.gender = selectedGender
                        userVM.currentUser?.pronouns = Array(selectedPronouns)
                        await userVM.saveOnboardingData()
                    }
                    viewModel.navigationPath.append(
                        OnboardingViewModel.OnboardingStep.dobAndStarSign)
                }
            }
        }
    }
}

#Preview {
    GenderPronounsView(viewModel: OnboardingViewModel())
        .environmentObject(UserViewModel.mock())
}
