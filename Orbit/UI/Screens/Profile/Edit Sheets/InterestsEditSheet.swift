//
//  InterestsEditSheet.swift
//  Orbit
//
//  Created by Nathaniel D'Orazio on 2025-03-29.
//

import SwiftUI
import Loaf

// Generic interests edit sheet
struct InterestsEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var userVM: UserViewModel
    
    let user: UserModel
    let section: String
    
    @State private var selectedItems: [String] = []
    @State private var availableItems: [String] = []
    @State private var selectedIntentions: [UserIntention] = []
    @State private var isSaving = false
    
    private var isIntentionsSection: Bool {
        return section == "intentions"
    }
    
    private var sectionTitle: String {
        switch section {
        case "activitiesHobbies": return "Activities and hobbies that bring me joy"
        case "friendActivities": return "What I'm interested in doing with friends"
        case "preferredMeetupType": return "How I like to meet people"
        case "convoTopics": return "Conversation topics I enjoy"
        case "friendshipValues": return "What I value most in a friendship"
        case "friendshipQualities": return "Qualities I look for in a friend"
        case "intentions": return "What brings me to Orbit"
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
        case "intentions": return "Select everything you hope to achieve with Orbit"
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
        case "intentions": return "Intentions"
        default: return section.capitalized
        }
    }
    
    init(user: UserModel, section: String) {
        self.user = user
        self.section = section
        
        // Initialize selected items based on section
        if section == "intentions" {
            _selectedIntentions = State(initialValue: user.intentions ?? [])
            _availableItems = State(initialValue: UserIntention.allCases.map { $0.rawValue })
        } else {
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
    }
    
    // Helper function to check if an item is selected
    private func isSelected(_ item: String) -> Bool {
        if isIntentionsSection {
            if let intention = UserIntention(rawValue: item) {
                return selectedIntentions.contains(intention)
            }
            return false
        } else {
            return selectedItems.contains(item)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ColorPalette.background(for: colorScheme)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    Text(promptText)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                        .padding(.horizontal)
                        .padding(.top)
                    
                    ScrollView {
                        // Use a single FlowLayout approach for both types
                        FlowLayout(items: isIntentionsSection ? 
                                  UserIntention.allCases.map { $0.rawValue } : 
                                  availableItems) { item in
                            Button(action: {
                                if isIntentionsSection {
                                    if let intention = UserIntention(rawValue: item) {
                                        if let index = selectedIntentions.firstIndex(of: intention) {
                                            selectedIntentions.remove(at: index)
                                        } else {
                                            selectedIntentions.append(intention)
                                        }
                                    }
                                } else {
                                    if selectedItems.contains(item) {
                                        selectedItems.removeAll { $0 == item }
                                    } else {
                                        selectedItems.append(item)
                                    }
                                }
                            }) {
                                Text(isIntentionsSection ? item.capitalized : item)
                                    .font(.subheadline)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(
                                        Capsule()
                                            .fill(isSelected(item) ?
                                                ColorPalette.accent(for: colorScheme) :
                                                ColorPalette.lightGray(for: colorScheme).opacity(0.5))
                                    )
                                    .foregroundColor(isSelected(item) ?
                                                   .white :
                                                   ColorPalette.text(for: colorScheme))
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
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                        }
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            isSaving = true
                            
                            Task {
                                if isIntentionsSection {
                                    await userVM.updateAndSaveUserData(
                                        intentions: selectedIntentions,
                                        sectionName: "Intentions"
                                    )
                                } else {
                                    // Update directly based on section
                                    switch section {
                                    case "activitiesHobbies":
                                        await userVM.updateAndSaveUserData(
                                            activitiesHobbies: selectedItems,
                                            sectionName: "Activities and hobbies"
                                        )
                                    case "friendActivities":
                                        await userVM.updateAndSaveUserData(
                                            friendActivities: selectedItems,
                                            sectionName: "Friend activities"
                                        )
                                    case "preferredMeetupType":
                                        await userVM.updateAndSaveUserData(
                                            preferredMeetupType: selectedItems,
                                            sectionName: "Meetup types"
                                        )
                                    case "convoTopics":
                                        await userVM.updateAndSaveUserData(
                                            convoTopics: selectedItems,
                                            sectionName: "Conversation topics"
                                        )
                                    case "friendshipValues":
                                        await userVM.updateAndSaveUserData(
                                            friendshipValues: selectedItems,
                                            sectionName: "Friendship values"
                                        )
                                    case "friendshipQualities":
                                        await userVM.updateAndSaveUserData(
                                            friendshipQualities: selectedItems,
                                            sectionName: "Friendship qualities"
                                        )
                                    default:
                                        break
                                    }
                                }
                                
                                dismiss()
                            }
                        }
                        .disabled(isSaving)
                        .foregroundColor(ColorPalette.accent(for: colorScheme))
                    }
                }
            }
        }
    }
}

#Preview {
    InterestsEditSheet(
        user: UserViewModel.mock().currentUser!,
        section: "intentions"
    )
    .environmentObject(UserViewModel.mock())
}
