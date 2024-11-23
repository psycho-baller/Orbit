//
//  AuthViewModel.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-10-06.
//  Copyright © 2024 CPSC 575. All rights reserved.
//

@preconcurrency import Appwrite
import Foundation
import JSONCodable
import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn = false {
        didSet {
            print("AuthViewModel - isLoggedIn: \(isLoggedIn)")
        }
    }
    @Published var error: String?
    @Published var user: User<[String: AnyCodable]>?
    @Published var isLoading = true

    private var account: AccountManagementServiceProtocol =
        AccountManagementService()

    @MainActor
    func initialize() async {
        await self.getAccount()
    }

    @MainActor
    private func getAccount() async {
        do {
            // Assuming `getAccount` can return `nil`, otherwise this check is not necessary.
            guard let user = try await account.getAccount() else {
                throw try AppwriteError(
                    from: "no user currently with a session" as! Decoder
                )
            }

            print(
                "AuthViewModel - getAccount: Success, user \(user.email) logged in."
            )

            // No need to use DispatchQueue.main.async because we're already on MainActor
            self.user = user
            self.isLoggedIn = true
        } catch {
            // Log the error and set the error property
            print(
                "AuthViewModel - Source: getAccount - Error: \(error.localizedDescription)"
            )
            self.error = error.localizedDescription
            self.isLoggedIn = false
        }

        // Update loading state on the main actor
        self.isLoading = false
    }

    @MainActor
    func create(name: String, email: String, password: String) async -> User<
        [String: AnyCodable]
    >? {
        do {
            let newUser = try await account.createAccount(email, password, name)
            print(
                "AuthViewModel - createAccount: Success, created account for \(newUser.email)."
            )
            await self.login(email: email, password: password)
            return newUser
        } catch {
            print(
                "AuthViewModel - Source: create - Error while creating account for \(email): \(error.localizedDescription)"
            )
            self.error = error.localizedDescription
            self.isLoggedIn = false
        }
        return nil
    }

    @MainActor
    func logout() async {
        do {
            try await account.deleteSession()
            print("AuthViewModel - logout: Success, session deleted.")
            self.isLoggedIn = false
            self.error = nil
        } catch {
            print(
                "AuthViewModel - Source: logout - Error: \(error.localizedDescription)"
            )
            self.error = error.localizedDescription
        }
    }

    @MainActor
    func loginAnonymous() async {
        do {
            try await account.createAnonymousSession()
            print(
                "AuthViewModel - loginAnonymous: Success, anonymous session created."
            )
            await self.getAccount()
        } catch {
            print(
                "AuthViewModel - Source: loginAnonymous - Error: \(error.localizedDescription)"
            )
            self.error = error.localizedDescription
        }
    }

    @MainActor
    func login(email: String, password: String) async {
        do {
            print("AuthViewModel - login: Attempting login for \(email).")
            try await account.createSession(email, password)
            print(
                "AuthViewModel - login: Success, session created for \(email).")

            guard let token = UserDefaults.standard.string(forKey: "apnsToken")
            else {
                return
            }
            print("token: \(token)")

            guard
                let target = try? await account.createPushTarget(
                    targetId: ID.unique(),
                    identifier: token
                )
            else {
                return
            }
            print("targetId: \(target.id)")

            UserDefaults.standard.set(target.id, forKey: "targetId")
            await self.getAccount()
        } catch {
            print(
                "AuthViewModel - Source: login - Error while logging in for \(email): \(error.localizedDescription)"
            )
            self.error = error.localizedDescription
        }
    }

    @MainActor
    func handleAccountCreationFailure() async {
        do {
            if let user = try await account.getAccount() {
                try await account.deleteAccount(user.id)
                print(
                    "AuthViewModel - handleAccountCreationFailure: Account deleted due to user creation failure in DB for user \(user.email)."
                )
            }
        } catch {
            print(
                "AuthViewModel - Source: handleAccountCreationFailure - Error while deleting account: \(error.localizedDescription)"
            )
        }
    }
}

// MARK: - Mock for SwiftUI Preview
#if DEBUG
    import SwiftUI

    extension AuthViewModel {
        static func mock() -> AuthViewModel {
            let viewModel = AuthViewModel()
            viewModel.isLoggedIn = true
            viewModel.isLoading = false
            viewModel.error = nil

            return viewModel
        }
    }
#endif
