//
//  MeetuprequestDetailedView.swift
//  Orbit
//
//  Created by Nathaniel D'Orazio on 2025-02-21.
//

import SwiftUI

struct MeetupRequestDetailedView: View {
    let meetupRequest: MeetupRequestDocument
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var meetupRequestVM: MeetupRequestViewModel
    @EnvironmentObject var chatVM: ChatViewModel
    @EnvironmentObject var userVM: UserViewModel
    @State private var areaName: String = ""
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ColorPalette.background(for: colorScheme)
                    .ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        Text(meetupRequest.data.createdByUser?.username ?? "")
                            .font(.title)
                            .padding(.bottom, 1)
                            .foregroundColor(Color.accentColor)
                            .lineLimit(1)

                        MeetupInfoSection(meetupRequest: meetupRequest)
                        //                        VStack(alignment: .leading, spacing: 20) {
                        // Interests Section
                        if let currentUser = userVM.currentUser,
                            let otherUser = meetupRequest.data.createdByUser
                        {

                            if let otherQualities = otherUser
                                .friendshipQualities,
                                !otherQualities.isEmpty,
                                let currentQualities = currentUser
                                    .friendshipQualities
                            {
                                TagSectionView(
                                    description:
                                        "What qualities do you look for in someone you’d like to meet?",
                                    otherUserTags: otherQualities,
                                    currentUserTags: currentQualities
                                )
                            }

                            if let otherValues = otherUser.friendshipValues,
                                !otherValues.isEmpty,
                                let currentValues = currentUser
                                    .friendshipValues
                            {
                                TagSectionView(
                                    description:
                                        "What do you value most in a friendship?",
                                    otherUserTags: otherValues,
                                    currentUserTags: currentValues
                                )
                            }

                            if let otherActivities = otherUser
                                .friendActivities,
                                !otherActivities.isEmpty,
                                let currentActivities = currentUser
                                    .friendActivities
                            {
                                TagSectionView(
                                    description:
                                        "What's something you'd love to find a friend to do with you?",
                                    otherUserTags: otherActivities,
                                    currentUserTags: currentActivities
                                )
                            }

                            if let otherHobbies = otherUser
                                .activitiesHobbies,
                                !otherHobbies.isEmpty,
                                let currentHobbies = currentUser
                                    .activitiesHobbies
                            {
                                TagSectionView(
                                    description:
                                        "What are some activities or hobbies that bring you joy?",
                                    otherUserTags: otherHobbies,
                                    currentUserTags: currentHobbies
                                )
                            }
                        }
                        if let bio = meetupRequest.data.createdByUser?.bio {
                            Text(bio)
                                .padding()
                        }
                        //                        }
                        Spacer().frame(height: 50)
                    }
                    .padding()
                }

                HStack(spacing: 16) {
                    Button(action: declineMeetupRequest) {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                            Text("Decline")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.red)
                        .cornerRadius(16)
                    }
                    Button(action: approveMeetupRequest) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Accept")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.green)
                        .cornerRadius(16)
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "person.crop.circle.badge.xmark")  //Other potential icons: "nosign", "shield.lefthalf.filled"
                            .foregroundColor(
                                ColorPalette.secondaryText(for: colorScheme))
                        #warning(
                            "TODO: Add block functionality"
                        )
                    }
                }
            }
        }
        .onAppear {
            areaName = userVM.getAreaName(forId: meetupRequest.data.areaId)
        }
    }

    private func approveMeetupRequest() {
        guard let sender = userVM.currentUser else {
            print("Error: Current user is nil.")
            return
        }

        let newChat = ChatModel(
            createdByUser: sender, otherUser: meetupRequest.data.createdByUser!,
            meetupRequest: meetupRequest.data
        )
        dismiss()

        Task {
            if let createdChat = await chatVM.createChat(chat: newChat) {
                appState.selectedTab = .messages
                appState.messagesNavigationPath.append(createdChat)
            }
        }
    }

    private func declineMeetupRequest() {
        Task {
            #warning(
                "TODO: Implement decline functionality"
            )
            dismiss()
        }
    }
}

#if DEBUG
    #Preview {
        @Previewable @Environment(\.colorScheme) var colorScheme

        NavigationStack {
            MeetupRequestDetailedView(meetupRequest: .mock())
                .environmentObject(UserViewModel.mock())
                .environmentObject(MeetupRequestViewModel.mock())
                .environmentObject(ChatViewModel.mock())
                .environmentObject(AppState())
                .accentColor(ColorPalette.accent(for: colorScheme))
        }
    }

#endif
