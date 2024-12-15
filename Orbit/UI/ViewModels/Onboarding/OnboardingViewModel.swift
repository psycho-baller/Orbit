//
//  OnboardingViewModel.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-12-15.
//

import SwiftUI

// Onboarding Data Model
class OnboardingViewModel: ObservableObject {
    
    @Published var navigationPath = NavigationPath()  // Store the stack path
    @Published var onboardingData: OnboardingData = OnboardingData()
    @Published var hasCompletedOnboarding = false  // Tracks if onboarding is completed

    enum OnboardingStep: String, CaseIterable, Hashable {
        case welcome, profileQuestions, socialStyle, interactionPreferences,
            friendshipValues, socialSituations, lifestylePreferences, complete
    }

    struct OnboardingData {
        var profileQuestions: [String]? = nil
        var socialStyle: [String]? = nil
        // Add other fields as needed
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        navigationPath.removeLast(navigationPath.count)  // Clear stack after completion
    }
}
