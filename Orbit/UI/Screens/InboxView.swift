//
//  InboxView.swift
//  Orbit
//
//  Created by Devon Tran on 2024-11-03.
//

import SwiftUI

struct InboxView: View {
    @EnvironmentObject private var msgVM: MessagingViewModel
    @EnvironmentObject private var userVM: UserViewModel
    @EnvironmentObject var appState: AppState
    @State private var showNewMessageView = false
    @Environment(\.colorScheme) var colorScheme
    @State private var isLoading = true

    var body: some View {
        NavigationStack(path: $appState.messagesNavigationPath) {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        ColorPalette.background(for: colorScheme),
                        ColorPalette.main(for: colorScheme),
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack {
                    if isLoading {
                        ProgressView("Loading Messages")
                            .padding()
                    } else if msgVM.conversations.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "message")
                                .font(.system(size: 70))
                                .foregroundColor(
                                    ColorPalette.secondaryText(for: colorScheme)
                                )
                            Text("No Messages")
                                .font(.title)
                                .foregroundColor(
                                    ColorPalette.text(for: colorScheme))
                            Text(
                                "When you start a conversation, it will appear here"
                            )
                            .font(.body)
                            .foregroundColor(
                                ColorPalette.secondaryText(for: colorScheme)
                            )
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        MessagesList(conversations: msgVM.conversations)
                    }
                }
                .frame(maxWidth: .infinity)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        HStack {
                            Text("Messages")
                                .largeBoldFont()
                        }
                        .foregroundColor(ColorPalette.text(for: colorScheme))
                    }
                }
            }
            .navigationDestination(for: ConversationDetailModel.self) {
                conversation in
                MessageView(
                    conversationId: conversation.id,
                    messagerName: conversation.messagerName
                )
            }
        }
        .onAppear {
            print(
                "InboxView - onAppear: Loading messages for user \(userVM.currentUser?.accountId ?? "nil")"
            )
            Task {
                isLoading = true
                await msgVM.initializeInbox(for: userVM.currentUser?.accountId)
                { fetchedConversations in
                    msgVM.conversations = fetchedConversations
                    isLoading = false
                }
            }
        }
        .onDisappear {
            Task {
                print("InboxView - Unsubscribed from messages")
                await msgVM.unsubscribeFromInboxMessages()
            }
        }
        .accentColor(.white)
    }
}
