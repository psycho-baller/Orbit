//
//  ProfilePageView.swift
//  Orbit
//
//  Created by Nathaniel D'Orazio on 2024-12-18.
//

#warning ("TODO: Fix bug where the first edit you select doesn't work")

import SwiftUI

struct ProfilePageView: View {
    let user: UserModel
    @Environment(\.colorScheme) var colorScheme
    @State private var orbitAngle: Double = 0
    @State private var editMode = false
    @State private var showingEditOptions = false
    @State private var currentEditSection: String = ""
    @State private var showingUnsavedChangesAlert = false
    
    // Determine if this is the current user's profile
    var isCurrentUserProfile: Bool
    
    @EnvironmentObject var userVM: UserViewModel
    
    // Use tempUserData when available, otherwise use the current user
    private var displayUser: UserModel {
        userVM.tempUserData ?? userVM.currentUser ?? user
    }

    #warning ("TODO: Find out why dates are formatted differently than expected when sent to the database. Is Appwrite doing it?") //Dates are expected to be formatted in "DateOnly" but are in "ISO8601"
    private var ageText: String {
        guard let dateString = displayUser.dob,
              let date = DateFormatterUtility.parseDateOnly(dateString) ?? DateFormatterUtility.parseISO8601(dateString)
        else {
            return ""
        }
        
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: date, to: Date())
        return ageComponents.year.map { "\($0)" } ?? ""
    }
    
    private var pronounsText: String {
        displayUser.pronouns.map { $0.rawValue }.joined(separator: "/")
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Main content
            ScrollView {
                // Add some padding at the top to make room for the floating edit button
                if isCurrentUserProfile {
                    Color.clear.frame(height: 50)
                }
                
                VStack(spacing: 20) {
                    // Profile Header with picture and orbiting interests
                    ZStack {
                        // Background gradient
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        ColorPalette.accent(for: colorScheme)
                                            .opacity(0.2),
                                        ColorPalette.background(for: colorScheme),
                                    ]),
                                    center: .center,
                                    startRadius: 5,
                                    endRadius: 150
                                )
                            )
                            .frame(maxWidth: .infinity)
                            .scaleEffect(1.5)
                            .padding()
                        
                        // Profile Picture
                        if let profileUrl = displayUser.profilePictureUrl,
                           let url = URL(string: profileUrl)
                        {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle().stroke(
                                            ColorPalette.accent(for: colorScheme),
                                            lineWidth: 2))
                                    .overlay(
                                        editMode ? editOverlay(for: "profile") : nil
                                    )
                            } placeholder: {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 120, height: 120)
                                    .foregroundColor(
                                        ColorPalette.secondaryText(for: colorScheme)
                                    )
                            }
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 120, height: 120)
                                .foregroundColor(
                                    ColorPalette.secondaryText(for: colorScheme)
                                )
                                .overlay(
                                    Circle().stroke(
                                        ColorPalette.accent(for: colorScheme),
                                        lineWidth: 2)
                                )
                                .overlay(
                                    editMode ? editOverlay(for: "profile") : nil
                                )
                        }
                        
                        // Orbiting Activities
                        if let activities = displayUser.activitiesHobbies, !activities.isEmpty {
                            OrbitContainer(interests: activities)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    // name, age, pronouns, username and bio
                    VStack(alignment: .center, spacing: 12) {
                        // name, age, pronouns
                        HStack(spacing: 8) {
                            Text(displayUser.firstName + " " + (displayUser.lastName ?? ""))
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(ColorPalette.text(for: colorScheme))
                            
                            if displayUser.showAge, !ageText.isEmpty {
                                Text(ageText)
                                    .font(.title3)
                                    .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                            }
                            
                            if displayUser.showPronouns, !pronounsText.isEmpty {
                                Text("\(pronounsText.capitalized)")
                                    .font(.title3)
                                    .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                            }
                        }
                        .overlay(
                            editMode ? editOverlay(for: "personalInfo") : nil
                        )
                        
                        
                        // Username
                        Text("@" + displayUser.username)
                            .font(.subheadline)
                            .foregroundColor(ColorPalette.accent(for: colorScheme))
                            .overlay(
                                editMode ? editOverlay(for: "username") : nil
                            )
                        
                        Spacer()
                        
                        // Bio
                        Text(displayUser.bio ?? "")
                            .font(.caption)
                            .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                            .overlay(
                                editMode ? editOverlay(for: "bio") : nil
                            )
                    }
                    .padding(.horizontal)
                    
                    // All interest fields from onboarding
                    VStack {
                        // Interests Section (choose up to 6 to display floating around profile pic)
                        if let activities = displayUser.activitiesHobbies, !activities.isEmpty {
                            ProfileTagSection(
                                title: "Interests",
                                items: activities,
                                isEditable: editMode,
                                onEdit: { editSection("interests") }
                            )
                        }
                        
                        // Friend Activities Section
                        if let friendActivities = displayUser.friendActivities, !friendActivities.isEmpty {
                            ProfileTagSection(
                                title: "Friend Activities",
                                items: friendActivities,
                                isEditable: editMode,
                                onEdit: { editSection("friendActivities") }
                            )
                        }
                        
                        // Meetup Types Section
                        if let meetupTypes = displayUser.preferredMeetupType, !meetupTypes.isEmpty {
                            ProfileTagSection(
                                title: "Preferred Meetups",
                                items: meetupTypes,
                                isEditable: editMode,
                                onEdit: { editSection("meetupTypes") }
                            )
                        }
                        
                        // Conversation Topics Section
                        if let convoTopics = displayUser.convoTopics, !convoTopics.isEmpty {
                            ProfileTagSection(
                                title: "Conversation Topics",
                                items: convoTopics,
                                isEditable: editMode,
                                onEdit: { editSection("convoTopics") }
                            )
                        }
                        
                        // Friendship Values Section
                        if let values = displayUser.friendshipValues, !values.isEmpty {
                            ProfileTagSection(
                                title: "Friendship Values",
                                items: values,
                                isEditable: editMode,
                                onEdit: { editSection("friendshipValues") }
                            )
                        }
                        
                        // Friendship Qualities Section
                        if let qualities = displayUser.friendshipQualities, !qualities.isEmpty {
                            ProfileTagSection(
                                title: "Friendship Qualities",
                                items: qualities,
                                isEditable: editMode,
                                onEdit: { editSection("friendshipQualities") }
                            )
                        }
                        
                        // Intentions Section
                        if let intentions = displayUser.intentions, !intentions.isEmpty {
                            ProfileTagSection(
                                title: "Intentions",
                                items: intentions.map { $0.rawValue },
                                isEditable: editMode,
                                onEdit: { editSection("intentions") }
                            )
                        }
                        
                        // Language Section
                        
                        // Social Links
                        
                    }
                    .padding(.horizontal)
                }
            }
            .background(ColorPalette.background(for: colorScheme))
            
            // Floating edit button
            if isCurrentUserProfile {
                Button(action: {
                    withAnimation(.spring()) {
                        if editMode {
                            // If exiting edit mode, check if there are changes
                            if userVM.hasUnsavedChanges {
                                // Show confirmation dialog
                                showingUnsavedChangesAlert = true
                            } else {
                                // No changes, just exit edit mode
                                editMode = false
                            }
                        } else {
                            // Enter edit mode
                            editMode = true
                        }
                    }
                }) {
                    if userVM.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding(12)
                    } else {
                        Image(systemName: editMode ? "checkmark.circle.fill" : "pencil.circle")
                            .font(.system(size: 22))
                            .foregroundColor(ColorPalette.accent(for: colorScheme))
                            .padding(12)
                    }
                }
                .disabled(userVM.isLoading)
                .padding(.top, 10)
                .padding(.trailing, 16)
                .zIndex(1) // Ensure it's above other content
                .confirmationDialog(
                    "Unsaved Changes",
                    isPresented: $showingUnsavedChangesAlert,
                    titleVisibility: .visible
                ) {
                    Button("Save Changes", role: .none) {
                        Task {
                            await userVM.saveProfileChanges()
                            editMode = false
                        }
                    }
                    
                    Button("Discard Changes", role: .destructive) {
                        userVM.discardProfileChanges()
                        editMode = false
                    }
                    
                    Button("Cancel", role: .cancel) {
                        // Stay in edit mode
                    }
                } message: {
                    Text("Save your changes?")
                }
            }
        }
        .sheet(isPresented: $showingEditOptions) {
            ProfileEditSheet(
                section: currentEditSection,
                user: displayUser
            )
            .environmentObject(userVM)
        }
    }
    
    
    // Helper function to create edit overlay
    private func editOverlay(for field: String) -> some View {
        ZStack(alignment: .topTrailing) {
            Color.clear
            
            Button(action: {
                editSection(field)
            }) {
                Image(systemName: "pencil.circle.fill")
                    .foregroundColor(ColorPalette.accent(for: colorScheme))
                    .background(Circle().fill(ColorPalette.background(for: colorScheme)))
                    .font(.system(size: 20))
            }
            .offset(x: 30, y: -5)
        }
    }
    
    // Function to handle editing different sections
    private func editSection(_ section: String) {
        currentEditSection = section
        showingEditOptions = true
    }
}

// Display section of tags
struct ProfileTagSection: View {
    let title: String
    let items: [String]
    var isEditable: Bool = false
    var onEdit: (() -> Void)? = nil
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                    .padding(.top, 10)
                
                Spacer()
                
                if isEditable {
                    Button(action: {
                        onEdit?()
                    }) {
                        Image(systemName: "pencil")
                            .foregroundColor(ColorPalette.accent(for: colorScheme))
                    }
                }
            }
            
            FlowLayout(items: items) { item in
                Text(item.capitalized)
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(ColorPalette.accent(for: colorScheme).opacity(0.2))
                    )
                    .foregroundColor(ColorPalette.accent(for: colorScheme))
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Preview
#if DEBUG
    #Preview {
        ProfilePageView(
            user: UserViewModel.mock().currentUser!,
            isCurrentUserProfile: true
        )
        .environmentObject(AuthViewModel())
        .environmentObject(UserViewModel.mock())
    }
#endif

//#Preview {
//    PreferenceSection(
//        title: "hiii",
//        items: [
//            "1OldFlowLayout", "2OldFlowLayout", "3", "4", "5", "6", "7", "8",
//            "9", "10",
//        ])
//}
