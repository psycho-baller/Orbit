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

struct UsernameEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var userVM: UserViewModel
    
    let user: UserModel
    
    @State private var username: String
    @State private var isUsernameAvailable: Bool? = nil
    @State private var isCheckingUsername = false
    @State private var debounceCancellable: AnyCancellable?
    
    init(user: UserModel) {
        self.user = user
        _username = State(initialValue: user.username)
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Choose a unique username")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                    .padding(.horizontal)
                
                TextField("Username", text: $username)
                    .padding()
                    .background(ColorPalette.lightGray(for: colorScheme))
                    .cornerRadius(10)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .onChange(of: username) { newValue in
                        checkUsernameAvailability(newValue)
                    }
                    .padding(.horizontal)
                
                // Username availability indicator
                if isCheckingUsername {
                    HStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                        Text("Checking availability...")
                            .font(.caption)
                            .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                    }
                    .padding(.horizontal)
                } else if let isAvailable = isUsernameAvailable {
                    Text(isAvailable ? "✅ Username available" : "❌ Username taken")
                        .foregroundColor(isAvailable ? .green : .red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.top)
            .navigationTitle("Edit Username")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if isUsernameAvailable == true && username != user.username {
                            // Update the view model with temporary changes
                            userVM.updateTempUserData(username: username)
                        }
                        dismiss()
                    }
                    .disabled(isUsernameAvailable != true && username != user.username)
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
            .sink { username in
                // In a real app, you'd call your API here
                // For now, let's simulate a check
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    // For demo purposes, let's say usernames ending with numbers are available
                    isUsernameAvailable = username.last?.isNumber ?? false || !username.contains(" ")
                    isCheckingUsername = false
                }
            }
    }
} 
