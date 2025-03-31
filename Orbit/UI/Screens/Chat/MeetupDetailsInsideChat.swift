//
//  MeetupDetailsInsideChat.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-03-30.
//
import SwiftUI

struct MeetupDetailsInsideChat: View {
    let user: UserModel
    let showFullDetails: Bool
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var userVM: UserViewModel

    var body: some View {
        ZStack(alignment: .top) {
            // Background (you might want to use the same background as MeetupRequestDetailedView)
            ColorPalette.background(for: colorScheme)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Profile header section.
                    if showFullDetails {
                        AsyncImage(
                            url: URL(
                                string: user.profilePictureUrl ?? "")
                        ) {
                            image in
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
                            description: "What I value in a friendship",
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
                                .frame(
                                    maxWidth: .infinity, alignment: .leading
                                )
                                .background(Color.blue.opacity(0.5))
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }

                    Spacer().frame(height: 50)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        //            .navigationTitle(user.username)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.accentColor)
                        Text("back to chat")
                    }
                }
            }
        }
    }
}

#Preview {
    // You must provide a UserModel.mock() for preview purposes.
    MeetupDetailsInsideChat(user: UserModel.mock(), showFullDetails: true)
        .environmentObject(UserViewModel.mock())
}
