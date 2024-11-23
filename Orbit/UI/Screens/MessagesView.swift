//
//  MessagesView.swift
//  Orbit
//
//  Created by Jessy Tseng on 2024-11-02.
//

import Appwrite
import SwiftUI

struct MessagesView: View {
    @EnvironmentObject private var msgVM: MessagingViewModel
    @EnvironmentObject private var userVM: UserViewModel
    var body: some View {
        VStack {
            Button("Create Conversation") {
                Task {
                    let accountIdBob = "6726b1ef776f5badc4fe"
                    if let currentAccountId = userVM.currentUser?.accountId {
                        await msgVM.createConversation([
                            currentAccountId, accountIdBob,
                        ])
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            Button("Get Conversations") {
                Task {
                    if let currentAccountId = userVM.currentUser?.accountId {
                        let conversations = await msgVM.getConversations(
                            currentAccountId)
                        print("conversations \(conversations)")
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .buttonStyle(.borderedProminent)
            Button("Send Message (Alice)") {
                Task {
                    let conversationId = "6726fe3b0728578a945a"
                    if let currentAccountId = userVM.currentUser?.accountId {
                        await msgVM.createMessage(
                            conversationId: conversationId,
                            senderAccountId: currentAccountId,
                            message: "Hello World")
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            Button("Send Message (Bob)") {
                Task {
                    let conversationId = "6726fe3b0728578a945a"
                    let accountIdBob = "6726b1ef776f5badc4fe"
                    await msgVM
                        .createMessage(
                            conversationId: conversationId,
                            senderAccountId: accountIdBob,
                            message: "Hello World"
                        )
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.mint)
            Button("Get Messages") {
                Task {
                    let conversationId = "6726fe3b0728578a945a"
                    let messages = await msgVM.getMessages(conversationId)
                    for msg in messages {
                        print(msg.data)
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
        }
    }
}

// MARK: - Preview
#if DEBUG
    #Preview {
        MessagesView()
            .environmentObject(AuthViewModel())
            .environmentObject(UserViewModel.mock())
            .environmentObject(MessagingViewModel())
    }
#endif
