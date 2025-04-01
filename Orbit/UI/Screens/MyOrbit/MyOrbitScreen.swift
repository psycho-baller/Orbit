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

    var userId: String? {
        userVM.currentUser?.id
    }

    var body: some View {
        NavigationView {
            ZStack {
                ColorPalette.background(for: colorScheme).edgesIgnoringSafeArea(
                    .all)

                if let userId = userId {
                    SuccessScreen(
                        userId: userId,
                        meetupRequestVM: meetupRequestVM)
                } else {
                    ErrorScreen()
                }
            }
            .accentColor(ColorPalette.accent(for: colorScheme))
            .navigationTitle("My Orbit")
            ZStack {
                ColorPalette.background(for: colorScheme).edgesIgnoringSafeArea(
                    .all)

                if let userId = userId {
                    SuccessScreen(
                        userId: userId,
                        meetupRequestVM: meetupRequestVM)
                } else {
                    ErrorScreen()
                }
            }
            .accentColor(ColorPalette.accent(for: colorScheme))
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
            (request.data.createdByUser?.id == userId
                || (request.data.chats ?? []).contains { (chat: ChatModel) in
                    chat.createdByUser?.id == userId
                })
                && request.data.status == .filled
        }
    }

    var myPendingMeetups: [MeetupRequestDocument] {
        meetupRequestVM.meetupRequests.filter { request in
            (request.data.chats ?? []).contains { (chat: ChatModel) in
                chat.createdByUser?.id == userId
                    && request.data.status != .filled
            }
        }
    }
    //    var myPendingMeetups: [MeetupRequestDocument] {
    //        meetupRequestVM.meetupRequests.compactMap { request in
    //            // Ensure the request isn't filled.
    //            guard request.data.status != .filled,
    //                  let chats = request.data.chats,
    //                  let matchingChat = chats.first(where: { $0.createdByUser?.id == userId })
    //            else {
    //                return nil
    //            }
    //            request.data.chats = [matchingChat]
    //            return request
    //            // Create a modified copy of the request's data with chats filtered to only include the matching chat.
    ////            var newData = request.data
    ////            newData.chats = [matchingChat]
    ////            // Now create a new MeetupRequestDocument with the modified data.
    ////            // Here we use a mock helper (or a custom initializer) to create a new document.
    ////            return MeetupRequestDocument.mock(data: newData)
    //        }
    //    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                MyOrbitSection(
                    title: "My Posts",
                    requests: myMeetupPosts,
                    destination: { request in
                        MyMeetupPostDetailScreen(meetupRequest: request)
                    }
                )

                MyOrbitSection(
                    title: "Confirmed Meetups",
                    requests: myConfirmedMeetups,
                    destination: { request in
                        Group {
                            if let chatToGoTo = request.data.chats?.first(
                                where: { chat in
                                    chat.meetupConfirmed
                                }),
                                let currentUser =
                                    (chatToGoTo.createdByUser?.id == userId
                                        ? chatToGoTo.createdByUser
                                        : chatToGoTo.otherUser)
                            {
                                    ChatDetailView(
                                        chat: .mock(data: chatToGoTo),
                                        user: currentUser)
                            } else {
                                EmptyView()
                            }
                        }
                    }
                )

                MyOrbitSection(
                    title: "Pending Requests",
                    requests: myPendingMeetups,
                    destination: { request in
                        Group {
                            if let chatToGoTo = request.data.chats?.first(
                                where: { chat in
                                    chat.createdByUser?.id == userId
                                }),
                                let currentUser = chatToGoTo.createdByUser
                            {
                                ChatDetailView(
                                    chat: .mock(data: chatToGoTo),
                                    user: currentUser)
                            } else {
                                EmptyView()
                            }
                        }
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
