//
//  UserDetailsView.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-02-22.
//  Copyright © 2024 CPSC 575. All rights reserved.
//

import Combine
import SwiftUI

struct UserDetailsView: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var username = ""
    private var usernameBinding: Binding<String> {
        Binding(
            get: { username },
            set: { newValue in
                username = newValue
                checkUsernameAvailability(newValue)  // Instant availability check
            }
        )
    }
    @State private var isUsernameAvailable: Bool? = nil
    @State private var navigateToOnboarding = false
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var debounceCancellable: AnyCancellable?

    let accountId: String

    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var navigationCoordinator: AuthNavigationCoordinator
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        AppwriteLogo {
            VStack {
                HStack {
                    Text("Complete Your Profile")
                        .largeSemiBoldFont()
                        .foregroundColor(ColorPalette.text(for: colorScheme))
                    Spacer()
                }

                Spacer().frame(height: 10)

                HStack {
                    Text("Tell us about yourself")
                        .largeLightFont()
                        .padding(.bottom)
                        .foregroundColor(
                            ColorPalette.secondaryText(for: colorScheme))
                    Spacer()
                }
                .padding(.bottom, 30)

                TextField("Username", text: usernameBinding)
                    .padding()
                    .background(ColorPalette.lightGray(for: colorScheme))
                    .cornerRadius(16.0)
                    .textInputAutocapitalization(.never)
                if let isAvailable = isUsernameAvailable {
                    Text(
                        isAvailable
                            ? "✅ Username available" : "❌ Username taken"
                    )
                    .foregroundColor(isAvailable ? .green : .red)
                    .font(.caption)
                    .padding(.top, 4)
                }

                TextField("First Name", text: self.$firstName)
                    .padding()
                    .background(ColorPalette.lightGray(for: colorScheme))
                    .cornerRadius(16.0)
                    .textInputAutocapitalization(.never)

                TextField("Last Name", text: self.$lastName)
                    .padding()
                    .background(ColorPalette.lightGray(for: colorScheme))
                    .cornerRadius(16.0)
                    .textInputAutocapitalization(.never)

                Spacer().frame(height: 16)

                LoadingButton(
                    title: "Complete Profile",
                    isLoading: isLoading,
                    isEnabled: isFormValid
                ) {
                    Task {
                        isLoading = true
                        do {
                            let myUser = UserModel(
                                accountId: accountId,
                                username: username,
                                firstName: firstName,
                                lastName: lastName
                            )

                            try await retryUserCreation(userData: myUser)
                            navigationCoordinator.navigateToRoot()
                        } catch {
                            print("Error: \(error.localizedDescription)")
                            errorMessage = error.localizedDescription
                        }
                        isLoading = false
                    }
                }
                .padding(.bottom, 20)

                Spacer()
            }
            .padding([.leading, .trailing], 27.5)
        }
        .background(ColorPalette.background(for: colorScheme))
        .accentColor(ColorPalette.accent(for: colorScheme))
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    Task {
                        navigationCoordinator.navigateToRoot()
                        isLoading = true
                        let deleted = await authVM.deleteAccount(accountId)
                        print("deleted: \(deleted)")

                        isLoading = false
                    }
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Cancel Account Creation")
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }

    private var isFormValid: Bool {
        !username.isEmpty && !firstName.isEmpty
            && (isUsernameAvailable ?? false)
    }

    /// Check if username is available using cached data
    func checkUsernameAvailability(_ newUsername: String) {
        guard newUsername.count > 2 else {
            isUsernameAvailable = nil
            return
        }
        isUsernameAvailable = userVM.isUsernameAvailable(newUsername)
    }

    func retryUserCreation(userData: UserModel, retries: Int = 3) async throws {
        var attempts = 0
        while attempts < retries {
            do {
                if let newUser = await userVM.createUser(userData: userData) {
                    return  // Success, break the loop
                } else {
                    attempts += 1
                    if attempts >= retries {
                        throw NSError(
                            domain: "User creation failed",
                            code: 500,
                            userInfo: nil
                        )
                    }
                    print("Retry \(attempts) failed, trying again...")
                }
            }
        }
    }
}

#Preview {
    UserDetailsView(accountId: "preview_id")
        .environmentObject(AuthViewModel())
        .environmentObject(UserViewModel())
}
