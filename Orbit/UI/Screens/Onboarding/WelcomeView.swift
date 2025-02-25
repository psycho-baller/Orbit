//
//  WelcomeView.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-12-15.
//
import SwiftUI

struct WelcomeView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack {
            Text("Welcome to the App!")
                .font(.largeTitle)

            Button("Start Onboarding") {
                viewModel.navigationPath.append(
                    OnboardingViewModel.OnboardingStep.intention)
            }
        }
        .padding()
        .navigationTitle("Welcome")
        .navigationBarTitleDisplayMode(.inline)
    }
}
#Preview {
    WelcomeView(viewModel: OnboardingViewModel())
}
