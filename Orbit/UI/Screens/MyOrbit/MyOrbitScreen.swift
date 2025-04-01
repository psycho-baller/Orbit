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
                        userId: userId)
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
                        userId: userId)
                } else {
                    ErrorScreen()
                }
            }
            .accentColor(ColorPalette.accent(for: colorScheme))
            .navigationTitle("My Orbit")
        }
    }
}

struct ChatDetailAsyncWrapper: View {
    let chatModel: ChatModel
    let currentUser: UserModel
    @EnvironmentObject var chatVM: ChatViewModel
    @State private var chatDocument: ChatDocument?

    var body: some View {
        Group {
            if let chatDocument = chatDocument {
                ChatDetailView(chat: chatDocument, user: currentUser)
            } else {
                ProgressView()
            }
        }
        .task {
            chatDocument = await chatVM.getChatDocument(chatId: chatModel.id)
        }
    }
}

// Success Screen (Shows meetup requests)
struct SuccessScreen: View {
    let userId: String
    @EnvironmentObject var meetupRequestVM: MeetupRequestViewModel
    @EnvironmentObject var chatVM: ChatViewModel

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
                                ChatDetailAsyncWrapper(
                                    chatModel: chatToGoTo,
                                    currentUser: currentUser)
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
                                ChatDetailAsyncWrapper(
                                    chatModel: chatToGoTo,
                                    currentUser: currentUser)
                            } else {
                                EmptyView()
                            }
                        }
                    }
                )
            }
            .padding()
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
