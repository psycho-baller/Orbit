//
//  MessagesView.swift
//  Orbit
//
//  Created by Jessy Tseng on 2024-11-02.
//

import SwiftUI
import Appwrite

struct MessagesView: View {
    @EnvironmentObject private var msgVM: MessagingViewModel
    @EnvironmentObject private var userVM: UserViewModel
    var body: some View {
        VStack {
            Button("Create Conversation") {
                Task {
                    if let currentUser = userVM.currentUser?.accountId {
                        await msgVM.createConversation([currentUser,"6726b1ef776f5badc4fe"])
                        // hard coded to bob
                    }
              }
            }
            .buttonStyle(.borderedProminent)
            Button("Get Conversations") {
                Task {
                    if let currentUser = userVM.currentUser?.accountId {
                        let conversations = await msgVM.getConversations(currentUser)
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
                    if let currentUser = userVM.currentUser?.accountId {
                        await msgVM.createMessage(conversationId, currentUser, "Hello World")
                    }
              }
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            Button("Send Message (Bob)") {
                Task {
                    let conversationId = "6726fe3b0728578a945a"
                    if let currentUser = userVM.currentUser?.accountId {
                        await msgVM.createMessage(conversationId, "6726b1ef776f5badc4fe", "Hello World")
                    }
              }
            }
            .buttonStyle(.borderedProminent)
            .tint(.mint)
            Button("Get Messages") {
                Task {
                    let conversationId = "6726fe3b0728578a945a"
                    let messages = await msgVM.getMessages(conversationId)
                    for msg in messages{
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
