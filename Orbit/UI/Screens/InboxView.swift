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
<<<<<<< HEAD
=======
    @Environment(\.colorScheme) var colorScheme  // Access color scheme from environment
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac

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
<<<<<<< HEAD
=======
            .background(ColorPalette.background(for: colorScheme))
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
            .frame(maxWidth: .infinity)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Text("Messages")
                            .largeBoldFont()
                    }
<<<<<<< HEAD
=======
                    .foregroundColor(ColorPalette.text(for: colorScheme))
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
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
<<<<<<< HEAD
                   //await msgVM.unsubscribeFromMessages()
                }
            }
        }
        .background(ColorPalette.background(for: ColorScheme.light))
=======
                    print("InboxView - Unsubscribed from messages")
                    await msgVM.unsubscribeFromInboxMessages()
                }
            }
        }
        .background(ColorPalette.background(for: colorScheme))
        .accentColor(.white)
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
    }
}
