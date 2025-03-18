//
//  UserErrorScreen.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-03-18.
//

import SwiftUI

struct ErrorScreen: View {
    @EnvironmentObject var userVM: UserViewModel  // Access user state
    @State private var isLoading = false  // Track loading state

    let title: String
    let description: String
    let buttonTitle: String
    let buttonIcon: String
    let retryAction: (() -> Void)?

    init(
        title: String = "Something went wrong",
        description: String =
            "We couldn't retrieve your user information. Please retry.",
        buttonTitle: String = "Retry",
        buttonIcon: String = "arrow.triangle.2.circlepath",
        retryAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.description = description
        self.buttonTitle = buttonTitle
        self.buttonIcon = buttonIcon
        self.retryAction = retryAction
    }

    var body: some View {
        VStack {
            Image("alien.sad")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)

            Text(title)
                .font(.title2)
                .foregroundColor(.primary)

            Text(description)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding()

            LoadingButton(
                title: buttonTitle,
                isLoading: isLoading,
                isEnabled: true,
                action: retryAction ?? defaultRetryAction,
                icon: buttonIcon
            )
            .padding(.horizontal, 40)
        }
        .padding()
    }

    private func defaultRetryAction() {
        isLoading = true
        Task {
            await userVM.fetchCurrentUser()  // Calls async function to fetch user
            isLoading = false
        }
    }
}

#Preview {
    ErrorScreen()
        .environmentObject(UserViewModel.mock())  // Ensure mock data is provided
}
