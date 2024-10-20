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

    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.presentationMode) var presentationMode

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
                    Text("Join Millions of\n other users!")
                        .largeSemiBoldFont()
                    Spacer()
                }

                Spacer().frame(height: 10)

                HStack {
                    Text("Create an account")
                        .largeLightFont()
                        .padding(.bottom)
                    Spacer()
                }
                .padding(.bottom, 30)

                TextField("Name", text: self.$name)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(16.0)

                TextField("E-mail", text: self.$email)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(16.0)

                SecureField("Password", text: self.$password)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(16.0)
                Spacer().frame(height: 16)
                Button("Create account") {
                    Task {
                        do {
                            // Step 1: Create account using auth
                            let newUser = try await authVM.create(
                                name: name, email: email, password: password)

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
                                interests: nil
                            )

                            try await retryUserCreation(userData: myUser)
                            print("Account and user created successfully")
                        } catch {
                            // Handle potential failures and roll back account creation
                            print("Error: \(error.localizedDescription)")
                            await authVM.handleAccountCreationFailure()
                        }
                    }
                }
                .regularFont()
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: 60)
                .background(Color.blue)
                .cornerRadius(16.0)

                Spacer()
            }
            .padding([.leading, .trailing], 27.5)
            .navigationBarHidden(true)
        }
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
