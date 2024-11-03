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
