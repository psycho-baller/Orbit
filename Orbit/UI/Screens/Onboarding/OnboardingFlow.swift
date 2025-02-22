//
//  OnboardingFlow.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-12-15.
//

import SwiftUI

struct OnboardingFlow: View {
    @StateObject private var viewModel = OnboardingViewModel()

    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            WelcomeView(viewModel: viewModel)
                .navigationDestination(
                    for: OnboardingViewModel.OnboardingStep.self
                ) { step in
                    switch step {
                    case .userInfo:
                        UserInfoView(onboardingVM: viewModel)
                    case .personalPreferences:
                        PersonalPreferencesView(onboardingVM: viewModel)
                    case .friendshipValues:
                        FriendshipValuesView(onboardingVM: viewModel)
                    case .interactionPreferences:
                        InteractionPreferencesView(onboardingVM: viewModel)
                    //                    case .complete:
                    //                        CompleteView(viewModel: viewModel)
                    default:
                        EmptyView()  // Fallback if no destination is matched
                    }
                }
        }
    }
}
