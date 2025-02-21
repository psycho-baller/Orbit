//
//  UserCardView.swift
//  Orbit
//
//  Created by Nathaniel D'Orazio on 2024-11-18.
//

import Foundation
import SwiftUI

struct UserCardView: View {
    let user: UserModel
    @EnvironmentObject var chatRequestVM: ChatRequestViewModel
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var isHidden = false

    var body: some View {
        if let currentUser = userVM.currentUser, !isHidden {
            NavigationLink(  // the parent checks if currentUser exists
                destination: UserProfileView(user: currentUser)
            ) {
                SwipeView {
                    HStack(spacing: 16) {
                        // Profile Picture
                        if let profileUrl = user.profilePictureUrl,
                            let url = URL(string: profileUrl)
                        {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(
                                        ColorPalette.secondaryText(
                                            for: colorScheme)
                                    )
                            }
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .foregroundColor(
                                    ColorPalette.secondaryText(for: colorScheme)
                                )
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            // User Name
                            Text(user.name)
                                .font(.title)
                                .padding(.bottom, 1)
                                .foregroundColor(Color.accentColor)
                                .lineLimit(1)

                            // User Interests
                            if let activities = user.personalPreferences?
                                .activitiesHobbies
                            {
                                InterestsHorizontalTags(
                                    interests: activities,
                                    onTapInterest: { activity in
                                        withAnimation {
                                            userVM.toggleInterest(activity)
                                        }
                                    }
                                )
                            } else {
                                InterestsHorizontalTags(
                                    interests: [],
                                    onTapInterest: { _ in }
                                )
                            }
                        }
                        .frame(height: 100)  // Fixed height for the entire VStack
                    }
                    .padding()
                    .background(ColorPalette.main(for: colorScheme))
                    .cornerRadius(32)
                } leadingActions: { _ in
                    SwipeAction {
                        sendQuickRequest()
                    } label: { isHighlighted in
                        VStack(spacing: 4) {
                            Image(systemName: "hand.wave.fill")
                                .font(.title2)
                            Text("Request")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                        .frame(width: 60)
                    } background: { isHighlighted in
                        ColorPalette.accent(for: colorScheme)
                            .opacity(isHighlighted ? 0.8 : 1)
                    }
                    .allowSwipeToTrigger()
                } trailingActions: { _ in
                    SwipeAction {
                        isHidden = true
                    } label: { isHighlighted in
                        VStack(spacing: 4) {
                            Image(systemName: "xmark.circle")
                                .font(.title2)
                            Text("Hide")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                        .frame(width: 60)
                    } background: { isHighlighted in
                        Color.red
                            .opacity(isHighlighted ? 0.8 : 1)
                    }
                    .allowSwipeToTrigger()
                }
                .swipeOffsetCloseAnimation(stiffness: 500, damping: 600)
                .swipeOffsetExpandAnimation(stiffness: 500, damping: 600)
                .swipeOffsetTriggerAnimation(stiffness: 500, damping: 600)
                .swipeMinimumDistance(20)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    private func sendQuickRequest() {
        guard let senderAccountId = userVM.currentUser?.accountId else {
            print("Error: Current user is nil.")
            return
        }

        let request = ChatRequestModel(
            senderAccountId: senderAccountId,
            receiverAccountId: user.accountId,
            message: "👋 Hi! Would you like to meet up?"
        )

        Task {
            await chatRequestVM.sendMeetUpRequest(
                request: request, from: userVM.currentUser?.name)
        }
    }
}
