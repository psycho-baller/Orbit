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

    @Environment(\.colorScheme) var colorScheme

    @State private var showCreateSheet = false


    @Environment(\.colorScheme) var colorScheme

    @State private var showCreateSheet = false


    var userId: String? {
        userVM.currentUser?.id
    }

    var body: some View {
        NavigationView {
            ZStack {
                ColorPalette.background(for: colorScheme).edgesIgnoringSafeArea(.all)

                if let userId = userId {
                    SuccessScreen(
                        userId: userId,
                        meetupRequestVM: meetupRequestVM)
                } else {
                    ErrorScreen()
                }
            }
            .accentColor(ColorPalette.accent(for :colorScheme))
            .navigationTitle("My Orbit")
            ZStack {
                ColorPalette.background(for: colorScheme).edgesIgnoringSafeArea(.all)

                if let userId = userId {
                    SuccessScreen(
                        userId: userId,
                        meetupRequestVM: meetupRequestVM)
                } else {
                    ErrorScreen()
                }
            }
            .accentColor(ColorPalette.accent(for :colorScheme))
            .navigationTitle("My Orbit")
        }
    }
}

// Success Screen (Shows meetup requests)
struct SuccessScreen: View {
    let userId: String
    @ObservedObject var meetupRequestVM: MeetupRequestViewModel

    var myMeetupPosts: [MeetupRequestDocument] {
        meetupRequestVM.meetupRequests.filter { request in
            request.data.createdByUser?.id == userId
                && request.data.status != .filled
        }
    }

    var myConfirmedMeetups: [MeetupRequestDocument] {
        meetupRequestVM.meetupRequests.filter { request in
            request.data.createdByUser?.id == userId
                || (request.data.chats ?? []).contains { (chat: ChatModel) in
                    chat.createdByUser?.id == userId
                }
                    && request.data.status == .filled
        }
    }

    var myPendingMeetups: [MeetupRequestDocument] {
    var myPendingMeetups: [MeetupRequestDocument] {
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
                    title: "My Posts",
                    requests: myMeetupPosts,
                    title: "My Posts",
                    requests: myMeetupPosts,
                    destination: { request in
                        MyMeetupPostDetailScreen(meetupRequest: request)
                        MyMeetupPostDetailScreen(meetupRequest: request)
                    }
                )

                MyOrbitSection(
                    title: "Confirmed Meetups",
                    requests: myConfirmedMeetups,
                    destination: { request in
                        ConfirmedMeetupScreen(meetupRequest: request)
                    }
                )

                MyOrbitSection(
                    title: "Pending Requests",
                    requests: myPendingMeetups,
                    title: "Pending Requests",
                    requests: myPendingMeetups,
                    destination: { request in
                        ApprovedMeetupScreen(meetupRequest: request)
                    }
                )
            }
            .padding()
        }
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
