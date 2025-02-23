//
//  LoginView.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-10-05.
//  Copyright 2024 CPSC 575. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isLoading = false

    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var navigationCoordinator: AuthNavigationCoordinator
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack(path: $navigationCoordinator.path) {
            AppwriteLogo {
                VStack {
                    HStack {
                        Text("Welcome back to\nOrbit")
                            .largeSemiBoldFont()
                            .padding(.top, 60)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(
                                ColorPalette.text(for: colorScheme))
                        Spacer()
                    }

                    Spacer().frame(height: 10)

                    HStack {
                        Text("Let's sign in.")
                            .largeLightFont()
                            .foregroundColor(
                                ColorPalette.secondaryText(for: colorScheme))
                        Spacer()
                    }
                    .padding(.bottom, 30)

                    TextField("E-mail", text: $email)
                        .padding()
                        .background(ColorPalette.lightGray(for: colorScheme))
                        .cornerRadius(16.0)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)

                    SecureField("Password", text: $password)
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
                        title: "Login",
                        isLoading: isLoading,
                        isEnabled: !email.isEmpty && !password.isEmpty && email.contains("@")
                    ) {
                        Task {
                            isLoading = true
                            await authVM.login(email: email, password: password)
                            if let currentUserAccountId = authVM.user?.id {
                                await userVM.updateCurrentUser(
                                    accountId: currentUserAccountId)
                            }
                            isLoading = false
                        }
                    }
                    .padding(.bottom, 20)

                    HStack {
                        Text("Anonymous Login")
                            .foregroundColor(.accentColor)
                            .onTapGesture {
                                Task { await authVM.loginAnonymous() }
                            }
                        Text(".")
                            .foregroundColor(.accentColor)
                        Text("Signup")
                            .foregroundColor(.accentColor)
                            .onTapGesture {
                                navigationCoordinator.navigateToSignup()
                            }
                    }
                    .regularFont()
                    .padding(.top, 30)
                    .padding(.bottom)

                    TermsAndPrivacyView(forButtonLabel: "Login")
                    Spacer()
                }
                .padding([.leading, .trailing], 40)
                .accentColor(ColorPalette.accent(for: colorScheme))
            }
            .background(ColorPalette.background(for: colorScheme))
            .navigationDestination(for: AuthDestination.self) { destination in
                switch destination {
                case .login:
                    LoginView()
                        .onAppear { print("Navigating to LoginView") }
                case .signup:
                    SignupView()
                        .onAppear { print("Navigating to SignupView") }
                case .userDetails(let accountId):
                    UserDetailsView(accountId: accountId)
                        .onAppear {
                            print(
                                "Navigating to UserDetailsView for accountId: \(accountId)"
                            )
                        }
                }
            }
        }
    }

    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && email.contains("@")
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthViewModel())
            .environmentObject(UserViewModel())
            .environmentObject(AppState())
            .environmentObject(AuthNavigationCoordinator())
    }
}
