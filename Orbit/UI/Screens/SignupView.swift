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
    @State private var showUserDetails = false
    @State private var accountId: String = ""
    @State private var errorMessage: String?

    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            AppwriteLogo {
                VStack {
                    HStack {
                        Image("back-icon")
                            .resizable()
                            .frame(width: 24, height: 21)
                            .onTapGesture {
                                presentationMode.wrappedValue.dismiss()
                            }
                        Spacer()
                    }
                    .padding([.top, .bottom], 30)

                    HStack {
                        Text("Join Orbit and become\nan Astronaut!")
                            .largeSemiBoldFont()
                            .foregroundColor(
                                ColorPalette.text(for: colorScheme))
                        Spacer()
                    }

                    Spacer().frame(height: 10)

                    HStack {
                        Text("Step 1: Create your account")
                            .largeLightFont()
                            .padding(.bottom)
                            .foregroundColor(
                                ColorPalette.secondaryText(for: colorScheme))
                        Spacer()
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

                    Button("Continue") {
                        guard password == confirmPassword else {
                            errorMessage = "Passwords do not match"
                            return
                        }
                        Task {
                            // Create account using auth with a temporary name
                            let newUser = await authVM.create(
                                email: email,
                                password: password
                            )

                            guard let newAccountId = newUser?.id else {
                                print("Error: User ID is nil")
                                return
                            }

                            accountId = newAccountId
                            showUserDetails = true
                        }
                    }
                    .regularFont()
                    .padding()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: 60)
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
                .navigationBarHidden(true)
                .navigationDestination(isPresented: $showUserDetails) {
                    UserDetailsView(accountId: accountId)
                }
            }
            .background(ColorPalette.background(for: colorScheme))
            .accentColor(ColorPalette.accent(for: colorScheme))
        }
    }

    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty
            && password == confirmPassword && email.contains("@")
    }
}

#Preview {
    SignupView()
        .environmentObject(AuthViewModel())
}
