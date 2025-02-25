//
//  SignupView.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-02-22.
//  Copyright 2024 CPSC 575. All rights reserved.
//

import SwiftUI

struct SignupView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @State private var isLoading = false

    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var navigationCoordinator: AuthNavigationCoordinator
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        AppwriteLogo {
            VStack {
                HStack {
                    Image("back-icon")
                        .resizable()
                        .frame(width: 24, height: 21)
                        .foregroundColor(ColorPalette.text(for: colorScheme))
                        .onTapGesture {
                            navigationCoordinator.navigateToRoot()
                        }
                    Spacer()
                }

                VStack(alignment: .leading, spacing: 16) {
                    Text("Join Orbit and become an Astronaut!")
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundColor(ColorPalette.text(for: colorScheme))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Step 1: Create your account")
                        .font(.system(size: 28))
                        .foregroundColor(
                            ColorPalette.secondaryText(for: colorScheme)
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.bottom, 30)

                TextField("E-mail", text: self.$email)
                    .padding()
                    .background(ColorPalette.lightGray(for: colorScheme))
                    .cornerRadius(16.0)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)

                SecureField("Password", text: self.$password)
                    .padding()
                    .background(ColorPalette.lightGray(for: colorScheme))
                    .cornerRadius(16.0)
                    .textInputAutocapitalization(.never)

                SecureField("Confirm Password", text: self.$confirmPassword)
                    .padding()
                    .background(ColorPalette.lightGray(for: colorScheme))
                    .cornerRadius(16.0)
                    .textInputAutocapitalization(.never)

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.top, 4)
                }

                Spacer().frame(height: 16)

                LoadingButton(
                    title: "Continue",
                    isLoading: isLoading,
                    isEnabled: isFormValid
                ) {
                    Task {
                        isLoading = true
                        guard password == confirmPassword else {
                            errorMessage = "Passwords do not match"
                            isLoading = false
                            return
                        }
                        // Create account using auth with a temporary name
                        let newUser = await authVM.create(
                            email: email,
                            password: password
                        )

                        guard let newAccountId = newUser?.id else {
                            print("Error: User ID is nil")
                            errorMessage = "Failed to create account"
                            isLoading = false
                            return
                        }

                        navigationCoordinator.navigateToUserDetails(
                            accountId: newAccountId)
                        isLoading = false
                    }
                }
                .padding()
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(
                    isFormValid
                        ? ColorPalette.accent(for: colorScheme)
                        : ColorPalette.accent(for: colorScheme).opacity(0.5)
                )
                .cornerRadius(16.0)
                .disabled(!isFormValid)

                TermsAndPrivacyView(forButtonLabel: "Join the community")
                    .padding(.top)

                Spacer()
            }
            .padding([.leading, .trailing], 27.5)
        }
        .background(ColorPalette.background(for: colorScheme))
        .accentColor(ColorPalette.accent(for: colorScheme))
//        .navigationBarHidden(true)
    }

    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty
            && password == confirmPassword && email.contains("@")
    }
}

#Preview {
    SignupView()
        .environmentObject(AuthViewModel())
        .environmentObject(AuthNavigationCoordinator())
}
//
