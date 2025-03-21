//
//  MyOrbitScreen.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-03-17.
//

import SwiftUI

struct MyOrbitScreen: View {
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var meetupRequestVM: MeetupRequestViewModel

    var userId: String? {
        userVM.currentUser?.id
    }

    var body: some View {
        NavigationView {
            if let userId = userId {
                SuccessScreen(
                    userId: userId,
                    meetupRequestVM: meetupRequestVM)
            } else {
                ErrorScreen()
            }
        }
    }
}

// Success Screen (Shows meetup requests)
struct SuccessScreen: View {
    let userId: String
    @ObservedObject var meetupRequestVM: MeetupRequestViewModel

    var myMeetupRequests: [MeetupRequestDocument] {
        meetupRequestVM.meetupRequests.filter { request in
            request.data.createdByUser?.id == userId
                && request.data.status != .filled
        }
    }

    var confirmedMeetups: [MeetupRequestDocument] {
        meetupRequestVM.meetupRequests.filter { request in
            (request.data.createdByUser?.id == userId
                || (request.data.chats ?? []).contains { (chat: ChatModel) in
                    chat.createdByUser?.id == userId
                })
                && request.data.status == .filled
        }
    }

    var approvedMeetups: [MeetupRequestDocument] {
        meetupRequestVM.meetupRequests.filter { request in
            (request.data.chats ?? []).contains { (chat: ChatModel) in
                chat.createdByUser?.id == userId
                    && request.data.status != .filled
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                MyOrbitSection(
                    title: "My Meetup Requests",
                    requests: myMeetupRequests,
                    destination: { request in
                        MyMeetupRequestDetailScreen(meetupRequest: request)
                    }
                )

                MyOrbitSection(
                    title: "Confirmed Meetups",
                    requests: confirmedMeetups,
                    destination: { request in
                        ConfirmedMeetupScreen(meetupRequest: request)
                    }
                )

                MyOrbitSection(
                    title: "Approved Meetups",
                    requests: approvedMeetups,
                    destination: { request in
                        ApprovedMeetupScreen(meetupRequest: request)
                    }
                )
            }
            .padding()
        }
        .navigationTitle("Meetup Requests")
        .onAppear {
            Task {
                //                await meetupRequestVM.fetchMeetupRequests(for: userId)
            }
        }
    }
}

#if DEBUG
    #Preview {
        MyOrbitScreen()
            .environmentObject(UserViewModel.mock())
            .environmentObject(MeetupRequestViewModel.mock())
    }
#endif
