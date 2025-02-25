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
    @Published var hasCompletedOnboarding = false  // Tracks if onboarding is completed

    // Define each step of the onboarding flow
    enum OnboardingStep: String, CaseIterable, Hashable {
        case welcome
        case intention                // What brings you to Orbit?
        case personalPreferences      // Combined screen for personal preferences questions
        case interactionPreferences   // Combined screen for interaction questions
        case friendshipValues         // Combined screen for friendship values
        case languages                // Languages you speak or want to learn
        case genderPronouns           // Gender & Pronouns
        case dobAndStarSign           // Date of Birth and optional star sign
        case userLinks                // Links to share
        case ageGroup                 // Which age group do you prefer to meetup with?
        case userInfo                 // In 50 words or less, how would you describe yourself?
        case complete
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        navigationPath.removeLast(navigationPath.count)  // Clear stack after completion
    }
}