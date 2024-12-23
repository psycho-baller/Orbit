//
//  LoginView.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-10-05.
//  Copyright © 2024 CPSC 575. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isActiveSignup = false

    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationView {
            AppwriteLogo {
                loginContent  // Use the shared loginContent to avoid duplication
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .background(ColorPalette.background(for: colorScheme))
        }
    }

    // The common content of the login page (used by both NavigationStack and NavigationView)
    var loginContent: some View {
        VStack {
            // Declare a NavigationLink with a value that matches your navigationDestination
            // Replace the old NavigationLink with navigationDestination
            //                    navigationDestination(isPresented: $isActiveSignup) {
            //                        SignupView() // Show SignupView when
            //                    }
            // Declare a NavigationLink with a value that matches your navigationDestination
            NavigationLink(
                destination: SignupView(), isActive: $isActiveSignup
            ) {
                EmptyView()
            }
            HStack {
                Text("Welcome back to\nOrbit")
                    .largeSemiBoldFont()
                    .padding(.top, 60)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(ColorPalette.text(for: colorScheme))
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

            SecureField("Password", text: $password)
                .padding()
                .background(ColorPalette.lightGray(for: colorScheme))
                .cornerRadius(16.0)
                .textInputAutocapitalization(.never)

            Spacer().frame(height: 16)

            Button("Login") {
                Task {
                    await authVM.login(email: email, password: password)
                    if let currentUserAccountId = authVM.user?.id {
                        await userVM.updateCurrentUser(
                            accountId: currentUserAccountId)
                    }
                }
            }
            .regularFont()
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: 50)
            .background(ColorPalette.accent(for: colorScheme))
            .cornerRadius(16.0)

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
                        isActiveSignup = true

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
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthViewModel())
            .environmentObject(UserViewModel())
            .environmentObject(AppState())

    }
}
