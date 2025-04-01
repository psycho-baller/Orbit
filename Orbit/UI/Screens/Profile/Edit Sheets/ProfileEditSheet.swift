//
//  ProfileEditSheet.swift
//  Orbit
//
//  Created by Nathaniel D'Orazio on 2025-03-29.
//

#warning ("TODO: Display the options from onboarding instead of hardcoding")

import SwiftUI

// Generic interests edit sheet
struct InterestsEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var userVM: UserViewModel
    
    let user: UserModel
    let section: String
    
    @State private var selectedItems: [String] = []
    @State private var availableItems: [String] = []
    @State private var isSaving = false
    
    private var sectionTitle: String {
        switch section {
        case "activitiesHobbies": return "Activities and hobbies that bring me joy"
        case "friendActivities": return "What I'm interested in doing with friends"
        case "preferredMeetupType": return "How I like to meet people"
        case "convoTopics": return "Conversation topics I enjoy"
        case "friendshipValues": return "What I value most in a friendship"
        case "friendshipQualities": return "Qualities I look for in a friend"
        default: return section.capitalized
        }
    }
    
    // More concise prompt text for the selection screen
    private var promptText: String {
        switch section {
        case "activitiesHobbies": return "Select your favourite activities and hobbies"
        case "friendActivities": return "Select activities you would like to do with friends"
        case "preferredMeetupType": return "Select your preferred meetup activities"
        case "convoTopics": return "Select topics you want to talk about"
        case "friendshipValues": return "Select your most important values in a friendship"
        case "friendshipQualities": return "Select your most important qualities in a friendship"
        default: return "Select options"
        }
    }
    
    // More concise navigation title
    private var navTitle: String {
        switch section {
        case "activitiesHobbies": return "Activities & Hobbies"
        case "friendActivities": return "Friend Activities"
        case "preferredMeetupType": return "Meetup Types"
        case "convoTopics": return "Conversation Topics"
        case "friendshipValues": return "Friendship Values"
        case "friendshipQualities": return "Friendship Qualities"
        default: return section.capitalized
        }
    }
    
    init(user: UserModel, section: String) {
        self.user = user
        self.section = section
        
        // Initialize selected items based on section
        var initialItems: [String] = []
        switch section {
        case "activitiesHobbies":
            initialItems = user.activitiesHobbies ?? []
            _availableItems = State(initialValue: OnboardingOptions.activitiesHobbies)
        case "friendActivities":
            initialItems = user.friendActivities ?? []
            _availableItems = State(initialValue: OnboardingOptions.friendActivities)
        case "preferredMeetupType":
            initialItems = user.preferredMeetupType ?? []
            _availableItems = State(initialValue: OnboardingOptions.preferredMeetupType)
        case "convoTopics":
            initialItems = user.convoTopics ?? []
            _availableItems = State(initialValue: OnboardingOptions.convoTopics)
        case "friendshipValues":
            initialItems = user.friendshipValues ?? []
            _availableItems = State(initialValue: OnboardingOptions.friendshipValues)
        case "friendshipQualities":
            initialItems = user.friendshipQualities ?? []
            _availableItems = State(initialValue: OnboardingOptions.friendshipQualities)
        default:
            _availableItems = State(initialValue: [])
        }
        
        _selectedItems = State(initialValue: initialItems)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text(promptText)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                    .padding(.horizontal)
                    .padding(.top)
                
                ScrollView {
                    FlowLayout(items: availableItems) { item in
                        Button(action: {
                            if selectedItems.contains(item) {
                                selectedItems.removeAll { $0 == item }
                            } else {
                                selectedItems.append(item)
                            }
                        }) {
                            Text(item)
                                .font(.subheadline)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(
                                    Capsule()
                                        .fill(selectedItems.contains(item) ?
                                            ColorPalette.lightGray(for: colorScheme) :
                                            ColorPalette.accent(for: colorScheme).opacity(0.2))
                                )
                                .foregroundColor(selectedItems.contains(item) ?
                                               ColorPalette.text(for: colorScheme) :
                                               ColorPalette.accent(for: colorScheme))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle(navTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        isSaving = true
                        
                        Task {
                            // Update directly based on section
                            switch section {
                            case "activitiesHobbies":
                                await userVM.updateAndSaveUserData(activitiesHobbies: selectedItems)
                            case "friendActivities":
                                await userVM.updateAndSaveUserData(friendActivities: selectedItems)
                            case "preferredMeetupType":
                                await userVM.updateAndSaveUserData(preferredMeetupType: selectedItems)
                            case "convoTopics":
                                await userVM.updateAndSaveUserData(convoTopics: selectedItems)
                            case "friendshipValues":
                                await userVM.updateAndSaveUserData(friendshipValues: selectedItems)
                            case "friendshipQualities":
                                await userVM.updateAndSaveUserData(friendshipQualities: selectedItems)
                            default:
                                break
                            }
                            
                            dismiss()
                        }
                    }
                    .disabled(isSaving)
                }
            }
        }
    }
}

// Intentions edit sheet
struct IntentionsEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var userVM: UserViewModel
    
    let user: UserModel
    
    @State private var selectedIntentions: [UserIntention] = []
    @State private var isSaving = false
    
    init(user: UserModel) {
        self.user = user
        _selectedIntentions = State(initialValue: user.intentions ?? [])
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("What brings you to Orbit?")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                    .padding(.horizontal)
                    .padding(.top)
                
                Text("Select everything you hope to achieve with Orbit")
                    .font(.subheadline)
                    .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                    .padding(.bottom)
                
                ScrollView {
                    FlowLayout(items: UserIntention.allCases.map { $0.rawValue }) { item in
                        Button(action: {
                            if let intention = UserIntention(rawValue: item),
                               let index = selectedIntentions.firstIndex(of: intention) {
                                selectedIntentions.remove(at: index)
                            } else if let intention = UserIntention(rawValue: item) {
                                selectedIntentions.append(intention)
                            }
                        }) {
                            Text(item.capitalized)
                                .font(.subheadline)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(
                                    Capsule()
                                        .fill(selectedIntentions.contains(where: { $0.rawValue == item }) ?
                                            ColorPalette.lightGray(for: colorScheme) :
                                            ColorPalette.accent(for: colorScheme).opacity(0.2))
                                )
                                .foregroundColor(selectedIntentions.contains(where: { $0.rawValue == item }) ?
                                               ColorPalette.text(for: colorScheme) :
                                               ColorPalette.accent(for: colorScheme))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("Intentions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        isSaving = true
                        
                        Task {
                            await userVM.updateAndSaveUserData(intentions: selectedIntentions)
                            dismiss()
                        }
                    }
                    .disabled(isSaving)
                }
            }
        }
    }
}

#Preview {
    IntentionsEditSheet(
        user: UserViewModel.mock().currentUser!
    )
    .environmentObject(UserViewModel.mock())
} 
