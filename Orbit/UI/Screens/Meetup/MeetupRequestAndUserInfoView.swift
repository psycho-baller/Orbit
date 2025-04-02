//
//  MeetupRequestAndUserInfoView.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-03-31.
//

import SwiftUI

struct MeetupRequestAndUserInfoView: View {
    let user: UserModel
    let meetupRequest: MeetupRequestDocument
    let showFullDetails: Bool
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile header section.
                if showFullDetails {
                    AsyncImage(
                        url: URL(string: user.profilePictureUrl ?? "")
                    ) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                    }
                    Text("\(user.firstName) \(user.lastName ?? "")")
                        .font(.title)
                        .foregroundColor(.accentColor)
                } else {
                    Text(user.username)
                        .font(.title)
                        .foregroundColor(.accentColor)
                }

                MeetupInfoSection(meetupRequest: meetupRequest)

                // Interests / Tags sections
                if let qualities = user.friendshipQualities,
                    !qualities.isEmpty
                {
                    TagSectionView(
                        description: "Qualities I look for in a friend",
                        otherUserTags: qualities,
                        currentUserTags: userVM.currentUser?
                            .friendshipQualities ?? []
                    )
                }

                if let values = user.friendshipValues, !values.isEmpty {
                    TagSectionView(
                        description: "What I value most in a friendship",
                        otherUserTags: values,
                        currentUserTags: userVM.currentUser?
                            .friendshipValues ?? []
                    )
                }

                if let activities = user.friendActivities,
                    !activities.isEmpty
                {
                    TagSectionView(
                        description: "Activities I love",
                        otherUserTags: activities,
                        currentUserTags: userVM.currentUser?
                            .friendActivities ?? []
                    )
                }

                if let hobbies = user.activitiesHobbies,
                    !hobbies.isEmpty
                {
                    TagSectionView(
                        description: "My hobbies",
                        otherUserTags: hobbies,
                        currentUserTags: userVM.currentUser?
                            .activitiesHobbies ?? []
                    )
                }

                // Bio section.
                if let bio = user.bio, !bio.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Bio")
                            .foregroundColor(.white.opacity(0.5))
                            .font(.caption)
                        Text(bio)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(ColorPalette.main(for: colorScheme))
                            .cornerRadius(10)
                    }
                }
                Spacer().frame(height: 50)
            }
            .padding()
        }
    }
}

#if DEBUG
    #Preview {
        @Previewable @Environment(\.colorScheme) var colorScheme
        MeetupRequestAndUserInfoView(
            user: .mock(), meetupRequest: .mock(), showFullDetails: true
        )
        .environmentObject(UserViewModel.mock())
        .accentColor(ColorPalette.accent(for: colorScheme))
    }
#endif
