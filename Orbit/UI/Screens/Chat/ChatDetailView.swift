//
//  ChatDetailView.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-03-14.
//

import SwiftUI

struct ChatDetailView: View {
    let chat: ChatDocument
    @EnvironmentObject var userVM: UserViewModel
    @StateObject var chatMessageVM: ChatMessageViewModel
    @State private var messageText: String = ""

    init(chat: ChatDocument) {
        self.chat = chat
        _chatMessageVM = StateObject(
            wrappedValue: ChatMessageViewModel(chatId: chat.id))
    }

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(chat.data.messages ?? [], id: \.id) { message in
                        MessageBubbleView(message: message)
                    }
                }
            }
            .padding()

            HStack {
                TextField("Type a message...", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                }
                .disabled(messageText.isEmpty)
            }
            .padding()
        }
        .navigationTitle(chat.data.meetupRequest?.title ?? "Chat")
        .onAppear {
            Task {
                await chatMessageVM.fetchMessages()
            }
        }
    }

    func sendMessage() {
        if let currentUser = userVM.currentUser {
            Task {
                let newMessage = ChatMessageModel(
                    sentByUser: currentUser,
                    chat: chat.data,
                    content: messageText
                )
                await chatMessageVM.sendMessage(message: newMessage)
                messageText = ""
            }
        } else {
            #warning("TODO: Handle this error. e.g. show toast")
            print("failed to send message: no current user")
        }
    }
}
