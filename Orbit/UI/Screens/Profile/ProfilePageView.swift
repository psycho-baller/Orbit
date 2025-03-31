//
//  ProfilePageView.swift
//  Orbit
//
//  Created by Nathaniel D'Orazio on 2024-12-18.
//


import SwiftUI

struct ProfilePageView: View {
    let user: UserModel
    @Environment(\.colorScheme) var colorScheme
    @State private var orbitAngle: Double = 0
    @State private var editMode = false
    @State private var activeSheet: ProfileEditType?
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
                        ZStack {
                            if let activities = displayUser.featuredInterests, !activities.isEmpty {
                                OrbitContainer(interests: activities)
                            }
                            
                            if editMode {
                                VStack {
                                    Spacer()
                                    Button(action: {
                                        editSection("featuredInterests")
                                    }) {
                                        Text(displayUser.featuredInterests?.isEmpty == false ? "Edit Featured Interests" : "Add Featured Interests")
                                            .font(.caption)
                                            .padding(.vertical, 6)
                                            .padding(.horizontal, 12)
                                            .background(
                                                Capsule()
                                                    .fill(ColorPalette.accent(for: colorScheme).opacity(0.2))
                                            )
                                            .foregroundColor(ColorPalette.accent(for: colorScheme))
                                            .overlay(
                                                Capsule()
                                                    .stroke(ColorPalette.accent(for: colorScheme), lineWidth: 1)
                                            )
                                    }
                                    .padding(.bottom, 10)  // Add padding to avoid overlapping with name
                                }
                            }
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
                        // Interests Section
                        ProfileTagSection(
                            title: "Interests",
                            items: displayUser.activitiesHobbies ?? [],
                            isEditable: editMode,
                            onEdit: { editSection("interests") },
                            showWhenEmpty: editMode
                        )
                        
                        // Friend Activities Section
                        ProfileTagSection(
                            title: "Friend Activities",
                            items: displayUser.friendActivities ?? [],
                            isEditable: editMode,
                            onEdit: { editSection("friendActivities") },
                            showWhenEmpty: editMode
                        )
                        
                        // Meetup Types Section
                        ProfileTagSection(
                            title: "Preferred Meetups",
                            items: displayUser.preferredMeetupType ?? [],
                            isEditable: editMode,
                            onEdit: { editSection("meetupTypes") },
                            showWhenEmpty: editMode
                        )
                        
                        // Conversation Topics Section
                        ProfileTagSection(
                            title: "Conversation Topics",
                            items: displayUser.convoTopics ?? [],
                            isEditable: editMode,
                            onEdit: { editSection("convoTopics") },
                            showWhenEmpty: editMode
                        )
                        
                        // Friendship Values Section
                        ProfileTagSection(
                            title: "Friendship Values",
                            items: displayUser.friendshipValues ?? [],
                            isEditable: editMode,
                            onEdit: { editSection("friendshipValues") },
                            showWhenEmpty: editMode
                        )
                        
                        // Friendship Qualities Section
                        ProfileTagSection(
                            title: "Friendship Qualities",
                            items: displayUser.friendshipQualities ?? [],
                            isEditable: editMode,
                            onEdit: { editSection("friendshipQualities") },
                            showWhenEmpty: editMode
                        )
                        
                        // Intentions Section
                        ProfileTagSection(
                            title: "Intentions",
                            items: displayUser.intentions?.map { $0.rawValue } ?? [],
                            isEditable: editMode,
                            onEdit: { editSection("intentions") },
                            showWhenEmpty: editMode
                        )
                        
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
                            // Enter edit mode and initialize tempUserData if it's nil
                            if userVM.tempUserData == nil && userVM.currentUser != nil {
                                userVM.tempUserData = userVM.currentUser
                            }
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
        .sheet(item: $activeSheet) { sheetType in
            switch sheetType {
            case .personalInfo:
                NameAgePronounEditSheet(user: userVM.tempUserData ?? userVM.currentUser ?? user)
                    .environmentObject(userVM)
            case .bio:
                BioEditSheet(user: userVM.tempUserData ?? userVM.currentUser ?? user)
                    .environmentObject(userVM)
            case .username:
                UsernameEditSheet(user: userVM.tempUserData ?? userVM.currentUser ?? user)
                    .environmentObject(userVM)
            case .profile:
                ProfilePictureEditSheet(user: userVM.tempUserData ?? userVM.currentUser ?? user)
                    .environmentObject(userVM)
            case .interests:
                InterestsEditSheet(user: userVM.tempUserData ?? userVM.currentUser ?? user, section: "activitiesHobbies")
                    .environmentObject(userVM)
            case .friendActivities:
                InterestsEditSheet(user: userVM.tempUserData ?? userVM.currentUser ?? user, section: "friendActivities")
                    .environmentObject(userVM)
            case .meetupTypes:
                InterestsEditSheet(user: userVM.tempUserData ?? userVM.currentUser ?? user, section: "preferredMeetupType")
                    .environmentObject(userVM)
            case .convoTopics:
                InterestsEditSheet(user: userVM.tempUserData ?? userVM.currentUser ?? user, section: "convoTopics")
                    .environmentObject(userVM)
            case .friendshipValues:
                InterestsEditSheet(user: userVM.tempUserData ?? userVM.currentUser ?? user, section: "friendshipValues")
                    .environmentObject(userVM)
            case .friendshipQualities:
                InterestsEditSheet(user: userVM.tempUserData ?? userVM.currentUser ?? user, section: "friendshipQualities")
                    .environmentObject(userVM)
            case .intentions:
                IntentionsEditSheet(user: userVM.tempUserData ?? userVM.currentUser ?? user)
                    .environmentObject(userVM)
            case .featuredInterests:
                FeaturedInterestsEditSheet(user: userVM.tempUserData ?? userVM.currentUser ?? user)
                    .environmentObject(userVM)
            }
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
        switch section {
        case "personalInfo": activeSheet = .personalInfo
        case "bio": activeSheet = .bio
        case "username": activeSheet = .username
        case "profile": activeSheet = .profile
        case "interests": activeSheet = .interests
        case "friendActivities": activeSheet = .friendActivities
        case "meetupTypes": activeSheet = .meetupTypes
        case "convoTopics": activeSheet = .convoTopics
        case "friendshipValues": activeSheet = .friendshipValues
        case "friendshipQualities": activeSheet = .friendshipQualities
        case "intentions": activeSheet = .intentions
        case "featuredInterests": activeSheet = .featuredInterests
        default: break
        }
    }
}

// Display section of tags
struct ProfileTagSection: View {
    let title: String
    let items: [String]
    var isEditable: Bool = false
    var onEdit: (() -> Void)? = nil
    var showWhenEmpty: Bool = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        // Only show if there are items or if showWhenEmpty is true
        if !items.isEmpty || showWhenEmpty {
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
                
                if items.isEmpty {
                    Text("Tap the pencil to add \(title.lowercased())")
                        .font(.subheadline)
                        .italic()
                        .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                        .padding(.vertical, 8)
                } else {
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
            }
            .padding(.horizontal)
        }
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

// Define an enum for the different sheet types
enum ProfileEditType: String, Identifiable {
    case personalInfo, bio, username, profile, interests, friendActivities, 
         meetupTypes, convoTopics, friendshipValues, friendshipQualities, 
         intentions, featuredInterests
    
    var id: String { rawValue }
}
