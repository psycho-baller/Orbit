//
//  FeaturedInterestEditSheet.swift
//  Orbit
//
//  Created by Nathaniel D'Orazio on 2025-03-31.
//

import SwiftUI

struct FeaturedInterestsEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var userVM: UserViewModel
    
    let user: UserModel
    let maxFeaturedInterests = 6
    
    @State private var selectedInterests: [String] = []
    @State private var availableInterests: [String] = []
    @State private var showAlert = false
    
    init(user: UserModel) {
        self.user = user
        
        // Initialize selected interests
        _selectedInterests = State(initialValue: user.featuredInterests ?? [])
        
        // Only use activities/hobbies for orbiting interests
        _availableInterests = State(initialValue: user.activitiesHobbies ?? [])
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Featured Interests")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(ColorPalette.text(for: colorScheme))
                    
                    Text("Select up to \(maxFeaturedInterests) interests to orbit around your profile picture")
                        .font(.subheadline)
                        .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Preview of orbiting interests
                ZStack {
                    Circle()
                        .fill(ColorPalette.background(for: colorScheme))
                        .frame(width: 100, height: 100)
                        .shadow(color: ColorPalette.accent(for: colorScheme).opacity(0.2), radius: 5)
                    
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                    
                    // Mini preview of orbiting interests
                    if !selectedInterests.isEmpty {
                        ForEach(Array(selectedInterests.prefix(6).enumerated()), id: \.element) { index, interest in
                            let count = min(selectedInterests.count, 6)
                            let angle = Double(index) * .pi * 2 / Double(count)
                            let xOffset = 60 * cos(angle)
                            let yOffset = 60 * sin(angle)
                            
                            Circle()
                                .fill(ColorPalette.accent(for: colorScheme))
                                .frame(width: 20, height: 20)
                                .offset(x: xOffset, y: yOffset)
                        }
                    }
                }
                .frame(height: 180)
                .padding(.vertical)
                
                // Selected interests
                VStack(alignment: .leading, spacing: 8) {
                    Text("Selected (\(selectedInterests.count)/\(maxFeaturedInterests))")
                        .font(.headline)
                        .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                    
                    if selectedInterests.isEmpty {
                        Text("No interests selected")
                            .italic()
                            .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                            .padding(.vertical, 8)
                    } else {
                        FlowLayout(items: selectedInterests) { item in
                            Button(action: {
                                withAnimation {
                                    selectedInterests.removeAll { $0 == item }
                                }
                            }) {
                                HStack {
                                    Text(item)
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.caption)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(ColorPalette.accent(for: colorScheme).opacity(0.2))
                                .foregroundColor(ColorPalette.accent(for: colorScheme))
                                .cornerRadius(20)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                Divider()
                    .padding(.vertical, 8)
                
                // Available interests
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Interests")
                            .font(.headline)
                            .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                            .padding(.horizontal)
                        
                        if availableInterests.isEmpty {
                            Text("You haven't added any activities or hobbies yet. Add some in your profile to feature them here.")
                                .italic()
                                .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                                .padding()
                                .multilineTextAlignment(.center)
                        } else {
                            FlowLayout(items: availableInterests) { item in
                                Button(action: {
                                    toggleInterest(item)
                                }) {
                                    Text(item)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(
                                            selectedInterests.contains(item)
                                                ? ColorPalette.accent(for: colorScheme)
                                                : ColorPalette.lightGray(for: colorScheme).opacity(0.5)
                                        )
                                        .foregroundColor(
                                            selectedInterests.contains(item)
                                                ? .white
                                                : ColorPalette.text(for: colorScheme)
                                        )
                                        .cornerRadius(20)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .background(ColorPalette.background(for: colorScheme))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        userVM.updateTempUserData(featuredInterests: selectedInterests)
                        dismiss()
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Maximum Reached"),
                    message: Text("You can select up to \(maxFeaturedInterests) featured interests."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func toggleInterest(_ interest: String) {
        if selectedInterests.contains(interest) {
            // Remove the interest
            selectedInterests.removeAll { $0 == interest }
        } else {
            // Add the interest if under the limit
            if selectedInterests.count < maxFeaturedInterests {
                selectedInterests.append(interest)
            } else {
                showAlert = true
            }
        }
    }
}
