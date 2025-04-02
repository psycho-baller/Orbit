//
//  UsernameEditSheet.swift
//  Orbit
//
//  Created by Nathaniel D'Orazio on 2025-03-29.
//

#warning ("TODO: Should username editing be a thing? Maybe limit it?")
#warning ("TODO: Actually check the username availability")

import SwiftUI
import Combine
import Loaf

struct UsernameEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var userVM: UserViewModel
    
    let user: UserModel
    
    @State private var username: String
    @State private var isCheckingUsername = false
    @State private var isUsernameAvailable: Bool?
    @State private var isSaving = false
    
    @State private var debounceCancellable: AnyCancellable?
    
    init(user: UserModel) {
        self.user = user
        _username = State(initialValue: user.username)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ColorPalette.background(for: colorScheme)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Choose a username")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                        .padding(.horizontal)
                    
                    TextField("Username", text: $username)
                        .padding()
                        .background(ColorPalette.lightGray(for: colorScheme))
                        .cornerRadius(10)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .onChange(of: username) { _ in
                            checkUsernameAvailability(username)
                        }
                        .padding(.horizontal)
                    
                    // Username availability indicator
                    HStack {
                        if isCheckingUsername {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                            Text("Checking availability...")
                                .font(.caption)
                                .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                        } else if let isAvailable = isUsernameAvailable {
                            if username == user.username {
                                // Current username
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("This is your current username")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            } else if isAvailable {
                                // Available username
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Username is available")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            } else {
                                // Unavailable username
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                Text("Username is not available or too short")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top)
                .navigationTitle("Edit Username")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                        }
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            if isUsernameAvailable == true && username != user.username {
                                isSaving = true
                                
                                Task {
                                    await userVM.updateAndSaveUserData(
                                        username: username,
                                        sectionName: "Username"
                                    )
                                    
                                    dismiss()
                                }
                            }
                        }
                        .disabled((isUsernameAvailable != true && username != user.username) || isSaving)
                        .foregroundColor(ColorPalette.accent(for: colorScheme))
                    }
                }
            }
        }
    }
    
    private func checkUsernameAvailability(_ username: String) {
        // Cancel any previous request
        debounceCancellable?.cancel()
        
        // If username is unchanged, it's available
        if username == user.username {
            isUsernameAvailable = true
            isCheckingUsername = false
            return
        }
        
        // If username is too short, don't check
        if username.count < 3 {
            isUsernameAvailable = false
            isCheckingUsername = false
            return
        }
        
        isCheckingUsername = true
        
        // Debounce the check to avoid too many requests
        debounceCancellable = Just(username)
            .delay(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { usernameToCheck in
                Task {
                    // Check availability with Firebase
                    let isAvailable = await userVM.isUsernameAvailable(usernameToCheck)
                    
                    // Update state on main thread
                    DispatchQueue.main.async {
                        isUsernameAvailable = isAvailable
                        isCheckingUsername = false
                    }
                }
            }
    }
}

#Preview {
    UsernameEditSheet(user: UserViewModel.mock().currentUser!)
        .environmentObject(UserViewModel.mock())
} 
