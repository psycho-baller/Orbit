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
    @State private var showNewMessageView = false
    @Environment(\.colorScheme) var colorScheme  // Access color scheme from environment

    var body: some View {
        NavigationStack {
            ScrollView {
                if msgVM.conversations.isEmpty {
                    ProgressView("Loading Messages")
                        .padding()
                } else {
                    MessagesList(conversations: msgVM.conversations)
                }
            }
            .background(ColorPalette.background(for: colorScheme))
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
            .onAppear {
                print(
                    "InboxView - onAppear: Loading messages for user \(userVM.currentUser?.accountId ?? "nil")"
                )
                Task {
                    await msgVM.initializeInbox(
                        for: userVM.currentUser?.accountId
                    ) { fetchedConversations in
                        msgVM.conversations = fetchedConversations
                        print("Debug", fetchedConversations)
                    }
                }
            }
            .onDisappear {
                Task {
                    print("InboxView - Unsubscribed from messages")
                    await msgVM.unsubscribeFromInboxMessages()
                }
            }
        }
        .background(ColorPalette.background(for: colorScheme))
        .accentColor(.white)
    }
}
