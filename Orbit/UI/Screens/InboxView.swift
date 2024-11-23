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
            .frame(maxWidth: .infinity)
            
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Text("Messages")
                            .largeBoldFont()
                    }
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
                    }
                }
            }
            .onDisappear {
                Task {
                   //await msgVM.unsubscribeFromMessages()
                }
            }
        }
        .background(ColorPalette.background(for: ColorScheme.light))
        .accentColor(.white)
    }
}
