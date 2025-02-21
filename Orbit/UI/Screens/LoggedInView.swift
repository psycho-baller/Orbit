//
//  LoggedInView.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-12-15.
//
import SwiftUI

struct LoggedInView: View {
    @EnvironmentObject var userVM: UserViewModel

    var body: some View {
        Group {
            if (userVM.currentUser?.hasCompletedOnboarding) == true {
                MainTabView()
            } else {
                OnboardingFlow()
            }
        }
        .onAppear {
            Task {
                await userVM.fetchCurrentUser()
            }
        }
    }
}
