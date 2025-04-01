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
    @State private var activeSheet: ProfileEditType?

    // Determine if this is the current user's profile
    var isCurrentUserProfile: Bool

    @EnvironmentObject var userVM: UserViewModel

    // Use current user when available, otherwise use the provided user
    private var displayUser: UserModel {
        userVM.currentUser ?? user
    }

    #warning(
        "TODO: Find out why dates are formatted differently than expected when sent to the database. Is Appwrite doing it?"
    )  //Dates are expected to be formatted in "DateOnly" but are in "ISO8601"
    private var ageText: String {
        guard let dateString = displayUser.dob,
            let date = DateFormatterUtility.parseDateOnly(dateString)
                ?? DateFormatterUtility.parseISO8601(dateString)
        else {
            return ""
        }

        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents(
            [.year], from: date, to: Date())
        return ageComponents.year.map { "\($0)" } ?? ""
    }

    // Format pronouns for display
    private var pronounsText: String {
        displayUser.pronouns.map { $0.rawValue }.joined(separator: "/")
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                // Profile Header with picture and orbiting interests
                VStack(spacing: 0) {
                    // Profile picture with orbiting interests
                    ZStack {
                        // Background gradient
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        ColorPalette.accent(for: colorScheme)
                                            .opacity(0.2),
                                        ColorPalette.background(
                                            for: colorScheme),
                                    ]),
                                    center: .center,
                                    startRadius: 5,
                                    endRadius: 150
                                )
                            )
                        
                        // Orbiting Activities
                        if let activities = displayUser.featuredInterests,
                            !activities.isEmpty
                        {
                            OrbitContainer(interests: activities)
                        }
                        
                        // Profile Picture - make it tappable if it's the current user
                        if isCurrentUserProfile {
                            Button {
                                activeSheet = .profile
                            } label: {
                                profilePictureView
                                    .overlay(
                                        Circle()
                                            .stroke(ColorPalette.accent(for: colorScheme), lineWidth: 2)
                                    )
                            }
                        } else {
                            profilePictureView
                                .overlay(
                                    Circle()
                                        .stroke(ColorPalette.accent(for: colorScheme), lineWidth: 2)
                                )
                        }
                    }
                    .padding(.top, 50)
                    
                    // Edit featured interests button
                    if isCurrentUserProfile {
                        Button {
                            activeSheet = .featuredInterests
                        } label: {
                            Text("Edit Featured Interests")
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(ColorPalette.accent(for: colorScheme).opacity(0.2))
                                )
                                .foregroundColor(ColorPalette.accent(for: colorScheme))
                        }
                    }
                    
                    // Name, age, pronouns, username and bio
                    VStack(alignment: .center, spacing: 12) {
                        // name, age, pronouns
                        VStack(alignment: .center, spacing: 4) {
                            // Name on its own line
                            Text(
                                displayUser.firstName + " "
                                    + (displayUser.lastName ?? "")
                            )
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(
                                ColorPalette.text(for: colorScheme)
                            )
                            .multilineTextAlignment(.center)
                            .lineLimit(2)

                            // Age, gender, and pronouns on a second line
                            HStack(spacing: 8) {
                                // Age display - always show if available
                                if !ageText.isEmpty {
                                    Text(ageText)
                                        .font(.title3)
                                        .foregroundColor(
                                            ColorPalette.secondaryText(
                                                for: colorScheme))
                                }

                                // Gender display
                                if let gender = displayUser.gender,
                                    displayUser.showGender
                                {
                                    // Add a separator dot if age is shown before gender
                                    if !ageText.isEmpty {
                                        Text("•")
                                            .font(.title3)
                                            .foregroundColor(
                                                ColorPalette.secondaryText(
                                                    for: colorScheme))
                                    }

                                    Text(gender.rawValue.capitalized)
                                        .font(.title3)
                                        .foregroundColor(
                                            ColorPalette.secondaryText(
                                                for: colorScheme))
                                }

                                // Add pronouns display
                                if displayUser.showPronouns,
                                    !pronounsText.isEmpty
                                {
                                    // Add a separator dot if either age or gender is shown before pronouns
                                    let showAgeBefore = !ageText.isEmpty
                                    let showGenderBefore =
                                        displayUser.gender != nil
                                        && displayUser.showGender
                                        && displayUser.gender != .other

                                    if showAgeBefore || showGenderBefore {
                                        Text("•")
                                            .font(.title3)
                                            .foregroundColor(
                                                ColorPalette.secondaryText(
                                                    for: colorScheme))
                                    }

                                    Text(pronounsText.capitalized)
                                        .font(.title3)
                                        .foregroundColor(
                                            ColorPalette.secondaryText(
                                                for: colorScheme))
                                }
                            }
                            .padding(.top, 2)
                        }
                        
                        // Edit button for personal info
                        if isCurrentUserProfile {
                            Button {
                                activeSheet = .personalInfo
                            } label: {
                                Text("Edit Personal Info")
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(ColorPalette.accent(for: colorScheme).opacity(0.2))
                                    )
                                    .foregroundColor(ColorPalette.accent(for: colorScheme))
                            }
                            .padding(.top, 4)
                        }
                    }
                    .padding(.top, 16)
                }
                .padding(.bottom, 16)
                
                // Profile content - different for current user vs other users
                if isCurrentUserProfile {
                    // Username Section
                    TappableSection(title: "Username", action: {
                        activeSheet = .username
                    }) {
                        Text("@\(displayUser.username)")
                            .font(.headline)
                            .foregroundColor(ColorPalette.accent(for: colorScheme))
                    }
                    .padding(.horizontal)
                    
                    // Bio Section
                    TappableSection(title: "Bio", action: {
                        activeSheet = .bio
                    }) {
                        if let bio = displayUser.bio, !bio.isEmpty {
                            Text(bio)
                                .font(.body)
                                .foregroundColor(ColorPalette.text(for: colorScheme))
                                .multilineTextAlignment(.leading)
                        } else {
                            Text("Tap to add a bio")
                                .font(.subheadline)
                                .italic()
                                .foregroundColor(ColorPalette.secondaryText(for: colorScheme).opacity(0.7))
                        }
                    }
                    .padding(.horizontal)
                    
                    // Activities & Hobbies Section
                    TappableProfileTagSection(
                        title: "Activities and hobbies that bring me joy",
                        items: displayUser.activitiesHobbies ?? [],
                        onTap: { activeSheet = .interests }
                    )
                    .padding(.horizontal)
                    
                    // Friend Activities Section
                    TappableProfileTagSection(
                        title: "Activities I'd love to do with friends",
                        items: displayUser.friendActivities ?? [],
                        onTap: { activeSheet = .friendActivities }
                    )
                    .padding(.horizontal)
                    
                    // Preferred Meetup Types Section
                    TappableProfileTagSection(
                        title: "Activities I enjoy doing with others",
                        items: displayUser.preferredMeetupType ?? [],
                        onTap: { activeSheet = .meetupTypes }
                    )
                    .padding(.horizontal)
                    
                    // Conversation Topics Section
                    TappableProfileTagSection(
                        title: "Conversation topics I enjoy",
                        items: displayUser.convoTopics ?? [],
                        onTap: { activeSheet = .convoTopics }
                    )
                    .padding(.horizontal)
                    
                    // Friendship Values Section
                    TappableProfileTagSection(
                        title: "What I value most in a friendship",
                        items: displayUser.friendshipValues ?? [],
                        onTap: { activeSheet = .friendshipValues }
                    )
                    .padding(.horizontal)
                    
                    // Friendship Qualities Section
                    TappableProfileTagSection(
                        title: "Qualities I look for in a friend",
                        items: displayUser.friendshipQualities ?? [],
                        onTap: { activeSheet = .friendshipQualities }
                    )
                    .padding(.horizontal)
                    
                    // Intentions Section
                    TappableProfileTagSection(
                        title: "What brings me to Orbit",
                        items: displayUser.intentions?.map { $0.rawValue } ?? [],
                        onTap: { activeSheet = .intentions }
                    )
                    .padding(.horizontal)
                } else {
                    // Non-editable view for other users' profiles
                    VStack(alignment: .leading, spacing: 24) {
                        // Basic Info
                        Text(user.firstName + " " + (user.lastName ?? ""))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(ColorPalette.text(for: colorScheme))

                        // Bio if available
                        if let bio = user.bio, !bio.isEmpty {
                            Text(bio)
                                .font(.body)
                                .foregroundColor(ColorPalette.text(for: colorScheme))
                                .padding(.bottom, 8)
                        }

                        // Interests Section
                        let interests = user.activitiesHobbies ?? []
                        if !interests.isEmpty {
                            ProfileTagSection(
                                title: "Activities and hobbies that bring me joy",
                                items: interests
                            )
                        }

                        if let activities = user.friendActivities, !activities.isEmpty {
                            ProfileTagSection(
                                title: "Activities I'd love to do with friends",
                                items: activities
                            )
                        }

                        if let meetups = user.preferredMeetupType, !meetups.isEmpty {
                            ProfileTagSection(
                                title: "Activities I enjoy doing with others",
                                items: meetups
                            )
                        }

                        if let topics = user.convoTopics, !topics.isEmpty {
                            ProfileTagSection(
                                title: "Conversation topics I enjoy",
                                items: topics
                            )
                        }

                        if let values = user.friendshipValues, !values.isEmpty {
                            ProfileTagSection(
                                title: "What I value most in a friendship",
                                items: values
                            )
                        }

                        if let qualities = user.friendshipQualities, !qualities.isEmpty {
                            ProfileTagSection(
                                title: "Qualities I look for in a friend",
                                items: qualities
                            )
                        }

                        if let intentions = user.intentions, !intentions.isEmpty {
                            ProfileTagSection(
                                title: "What brings me to Orbit",
                                items: intentions.map { $0.rawValue }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .background(ColorPalette.background(for: colorScheme))
        .edgesIgnoringSafeArea(.top)
        .sheet(item: $activeSheet) { sheetType in
            // Sheet presentations
            switch sheetType {
            case .personalInfo:
                NameAgePronounEditSheet(user: displayUser)
                    .environmentObject(userVM)
            case .bio:
                BioEditSheet(user: displayUser)
                    .environmentObject(userVM)
            case .username:
                UsernameEditSheet(user: displayUser)
                    .environmentObject(userVM)
            case .profile:
                ProfilePictureEditSheet(user: displayUser)
                    .environmentObject(userVM)
            case .interests:
                InterestsEditSheet(
                    user: displayUser,
                    section: "activitiesHobbies"
                )
                .environmentObject(userVM)
            case .friendActivities:
                InterestsEditSheet(
                    user: displayUser,
                    section: "friendActivities"
                )
                .environmentObject(userVM)
            case .meetupTypes:
                InterestsEditSheet(
                    user: displayUser,
                    section: "preferredMeetupType"
                )
                .environmentObject(userVM)
            case .convoTopics:
                InterestsEditSheet(
                    user: displayUser,
                    section: "convoTopics"
                )
                .environmentObject(userVM)
            case .friendshipValues:
                InterestsEditSheet(
                    user: displayUser,
                    section: "friendshipValues"
                )
                .environmentObject(userVM)
            case .friendshipQualities:
                InterestsEditSheet(
                    user: displayUser,
                    section: "friendshipQualities"
                )
                .environmentObject(userVM)
            case .intentions:
                IntentionsEditSheet(user: displayUser)
                    .environmentObject(userVM)
            case .featuredInterests:
                FeaturedInterestsEditSheet(user: displayUser)
                    .environmentObject(userVM)
            }
        }
    }

    // Profile picture view
    private var profilePictureView: some View {
        Group {
            if let profileUrl = displayUser.profilePictureUrl,
                let url = URL(string: profileUrl)
            {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                } placeholder: {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .foregroundColor(
                            ColorPalette.secondaryText(
                                for: colorScheme)
                        )
                }
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .foregroundColor(
                        ColorPalette.secondaryText(for: colorScheme)
                    )
            }
        }
    }
}

// Display section of tags
struct ProfileTagSection: View {
    let title: String
    let items: [String]
    var isEditable: Bool = false
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
                        .foregroundColor(
                            ColorPalette.secondaryText(for: colorScheme)
                        )
                        .padding(.top, 10)

                    Spacer()

                    if isEditable {
                        Button(action: {
                            // Implement edit action
                        }) {
                            Image(systemName: "pencil")
                                .foregroundColor(
                                    ColorPalette.accent(for: colorScheme))
                        }
                    }
                }

                if items.isEmpty {
                    Text("Tap the pencil to add \(title.lowercased())")
                        .font(.subheadline)
                        .italic()
                        .foregroundColor(
                            ColorPalette.secondaryText(for: colorScheme)
                        )
                        .padding(.vertical, 8)
                } else {
                    FlowLayout(items: items) { item in
                        Text(item.capitalized)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(
                                        ColorPalette.accent(for: colorScheme)
                                            .opacity(0.2))
                            )
                            .foregroundColor(
                                ColorPalette.accent(for: colorScheme))
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

// Define an enum for the different sheet types
enum ProfileEditType: String, Identifiable {
    case personalInfo, bio, username, profile, interests, friendActivities,
        meetupTypes, convoTopics, friendshipValues, friendshipQualities,
        intentions, featuredInterests

    var id: String { rawValue }
}
