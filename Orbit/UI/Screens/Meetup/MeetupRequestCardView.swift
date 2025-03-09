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
                destination: MeetupRequestDetailedView(
                    meetupRequest: meetupRequest)
            ) {
                SwipeView {
                    HStack(spacing: 16) {
                        // Profile Picture
                        if let profileUrl = meetupRequest.createdByUser?
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
                            Text(meetupRequest.createdByUser?.username ?? "")
                                .font(.headline)
                                .foregroundColor(Color.accentColor)
                                .lineLimit(1)

                            // Meetup Title
                            Text(meetupRequest.title)
                                .font(.body)
                                .foregroundColor(
                                    ColorPalette.text(for: colorScheme)
                                )
                                .lineLimit(2)

                            // Time
                            Text(formatMeetupTime(meetup: meetupRequest))
                                .font(.subheadline)
                                .foregroundColor(
                                    ColorPalette.secondaryText(for: colorScheme)
                                )
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
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
            //            approvedByUserId: sender.id,
            approvedByUser: sender,
            //            meetupRequestId: meetupRequest.id,
            meetupRequest: meetupRequest, firstMessage: ""
        )

        Task {
            await meetupApprovalVM.approveMeetup(approval: meetupApproval)
        }
    }

    private func formatMeetupTime(meetup: MeetupRequestModel) -> String {
        guard let startTime = meetup.startTimeDate,
            let endTime = meetup.endTimeDate
        else {
            return "Invalid date"
        }

        let now = Date()

        // If current time is between start and end time
        if now >= startTime && now <= endTime {
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            return "Now until \(formatter.string(from: endTime))"
        }

        // If start time is within the next hour
        let minutesUntilStart =
            Calendar.current.dateComponents([.minute], from: now, to: startTime)
            .minute ?? 0
        if minutesUntilStart > 0 && minutesUntilStart < 60 {
            return "in \(minutesUntilStart) minutes"
        }

        // Otherwise show the start time
        let formatter = DateFormatter()
        let isToday = Calendar.current.isDate(startTime, inSameDayAs: Date())

        if isToday {
            formatter.dateStyle = .none
            formatter.timeStyle = .short
        } else {
            formatter.dateStyle = .long
            formatter.timeStyle = .short
        }
        return formatter.string(from: startTime)
    }
}

#Preview {
    MeetupRequestCardView(meetupRequest: .mock())
        .environmentObject(MeetupRequestViewModel.mock())
        .environmentObject(MeetupApprovalViewModel.mock())
        .environmentObject(UserViewModel.mock())
}
