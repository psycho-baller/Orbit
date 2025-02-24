//
//  MeetupRequestCardView.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-02-20.
//

import SwiftUI

struct MeetupRequestCardView: View {
    let meetupRequest: MeetupRequestModel
    @EnvironmentObject var meetupRequestVM: MeetupRequestViewModel
    @EnvironmentObject var meetupApprovalVM: MeetupApprovalViewModel
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var isHidden = false

    var body: some View {
        if !isHidden {
            NavigationLink(
                destination: MeetupRequestDetailedView(meetupRequest: meetupRequest)
            ) {
                #warning(
                    "TODO: Refactor this to match the new design while using the data from 'meetupRequest'"
                )
                SwipeView {
                    HStack(spacing: 16) {
                        // Profile Picture
                        if let profileUrl = meetupRequest.createdBy
                            .profilePictureUrl,
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
                                            for: colorScheme))
                            }
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .foregroundColor(
                                    ColorPalette.secondaryText(
                                        for: colorScheme)
                                )
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            // User Name
                            Text(meetupRequest.createdBy.username)
                                .font(.title)
                                .padding(.bottom, 1)
                                .foregroundColor(Color.accentColor)
                                .lineLimit(1)

                            // User Interests
                            if let activities = meetupRequest.createdBy
                                .personalPreferences?
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
                                    interests: [], onTapInterest: { _ in })
                            }
                        }
                        .frame(height: 100)
                    }
                    .padding()
                    .background(ColorPalette.main(for: colorScheme))
                    .cornerRadius(32)
                } leadingActions: { _ in
                    SwipeAction {
                        approveMeetupRequest()
                    } label: { isHighlighted in
                        VStack(spacing: 4) {
                            Image(systemName: "calendar.badge.plus")
                                .font(.title2)
                            Text("Meetup")
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

    private func approveMeetupRequest() {
        guard let sender = userVM.currentUser else {
            print("Error: Current user is nil.")
            return
        }

        let meetupApproval = MeetupApprovalModel(
            approvedBy: sender, meetupRequest: meetupRequest, firstMessage: ""
        )

        Task {
            await meetupApprovalVM.approveMeetup(approval: meetupApproval)
        }
    }
}

#Preview {
    MeetupRequestCardView(meetupRequest: .mock())
        .environmentObject(MeetupRequestViewModel.mock())
        .environmentObject(MeetupApprovalViewModel.mock())
        .environmentObject(UserViewModel.mock())
}
