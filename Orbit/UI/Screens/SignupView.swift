//
//  SignupView.swift
//  Appwrite Jobs
//
//  Created by Damodar Lohani on 11/10/2021.
//

import SwiftUI

struct SignupView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var navigateToOnboarding = false

    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
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
                        .foregroundColor(ColorPalette.text(for: colorScheme))
                    Spacer()
                }

                Spacer().frame(height: 10)

                HStack {
                    Text("Join the community")
                        .largeLightFont()
                        .padding(.bottom)
                        .foregroundColor(
                            ColorPalette.secondaryText(for: colorScheme))
                    Spacer()
                }
                .padding(.bottom, 30)

                TextField("Name", text: self.$name)
                    .padding()
                    .background(ColorPalette.lightGray(for: colorScheme))
                    .cornerRadius(16.0)
                    .textInputAutocapitalization(.never)

                TextField("E-mail", text: self.$email)
                    .padding()
                    .background(ColorPalette.lightGray(for: colorScheme))
                    .cornerRadius(16.0)
                    .textInputAutocapitalization(.never)

                SecureField("Password", text: self.$password)
                    .padding()
                    .background(ColorPalette.lightGray(for: colorScheme))
                    .cornerRadius(16.0)
                    .textInputAutocapitalization(.never)
                Spacer().frame(height: 16)

                Button("Create account") {
                    Task {
                        do {
                            // Step 1: Create account using auth
                            let newUser = try await authVM.create(
                                name: name, email: email, password: password
                            )

                            // Step 2: Ensure the account creation was successful
                            guard let userId = newUser?.id,
                                let userName = newUser?.name
                            else {
                                print("Error: User ID or Name is nil")
                                return
                            }

                            // Step 3: Create a corresponding user in the database
                            let myUser = UserModel(
                                accountId: userId,
                                name: userName,
                                interests: nil,
                                personalPreferences: nil,
                                socialStyle: nil,
                                interactionPreferences: nil,
                                friendshipValues: nil,
                                socialSituations: nil
                            )

                            try await retryUserCreation(userData: myUser)
                            print("Account and user created successfully")
                            presentationMode.wrappedValue.dismiss()  // close the signup view

                            // Navigate to onboarding flow
                        } catch {
                            // Handle potential failures and roll back account creation
                            print("Error: \(error.localizedDescription)")
                            await authVM.handleAccountCreationFailure()
                        }
                    }
                }

                .regularFont()
                .padding()
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: 60)
                .background(ColorPalette.accent(for: colorScheme))
                .cornerRadius(16.0)

                TermsAndPrivacyView(forButtonLabel: "Join the community")
                    .padding(.top)

                Spacer()
            }
            .padding([.leading, .trailing], 27.5)
            .navigationBarHidden(true)

        }
        .background(ColorPalette.background(for: colorScheme))
        .accentColor(ColorPalette.accent(for: colorScheme))
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

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView()
            .environmentObject(AuthViewModel())
            .environmentObject(UserViewModel())
    }
}
