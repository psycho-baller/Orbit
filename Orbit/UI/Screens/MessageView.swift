//
//  MessageView.swift
//  Orbit
//
//  Created by Devon Tran on 2024-11-01.
//

import SwiftUI

struct MessageView: View {
    @EnvironmentObject private var msgVM: MessagingViewModel
    @EnvironmentObject private var userVM: UserViewModel

    @State private var newMessageText: String = ""
    @State private var scrollToId: String?  // Save the last message ID for scroll position
    let conversationId: String
    let messagerName: String

    var body: some View {
        VStack {
            VStack {
                // Chat Header
                ChatProfileTitle(
                    messagerName: messagerName, isInMessageView: true)

                ScrollViewReader { proxy in
                    ScrollView {
                        ForEach($msgVM.messages, id: \.id) { $messageDocument in
                            if !messageDocument.data.senderAccountId.isEmpty {
                                MessageBox(messageDocument: messageDocument)
                                    .id(messageDocument.id)  // Assign unique ID to each message
                            }
                        }
                    }
                    .onChange(of: msgVM.lastMessageId) { newMessageId in
                        if let id = newMessageId {
                            withAnimation {
                                proxy.scrollTo(id, anchor: .bottom)
                            }
                        }
                    }
                    .onAppear {
                        if let id = msgVM.lastMessageld.wrappedValue {
                            withAnimation {
                                proxy.scrollTo(id, anchor: .bottom)
                            }
                        }
                    }
                }
                .padding(.top, 10)
                .background(.white)
                .cornerRadius(radius: 30, corners: [.topLeft, .topRight])
            }
            .background(ColorPalette.accent(for: ColorScheme.light))

            // Message Input Field
            MessageField(text: $newMessageText, onSend: sendMessage)
        }
        .onAppear {
            Task {
                // Fetch messages and subscribe to updates
                await msgVM.getMessages(conversationId)
                await msgVM.subscribeToMessages(
                    conversationId: conversationId
                ) { newMessage in
                    print(
                        "Received new message: \(newMessage.data.message)")

                    if !msgVM.messages.contains(where: {
                        $0.id == newMessage.id
                    }) {
                        msgVM.messages.append(newMessage)
                        msgVM.messages.sort { $0.createdAt < $1.createdAt }
                        msgVM.lastMessageId = newMessage.id
                    }
                }
                await msgVM.markMessagesRead(conversationId: conversationId)
            }
        }
        .onDisappear {
            Task {
                await msgVM.unsubscribeFromMessages()
            }
        }
        .toolbar(.hidden, for: .tabBar)
    }
    private func sendMessage() {
        Task {
            if let senderId = userVM.currentUser?.accountId {
                await msgVM.createMessage(
                    conversationId: conversationId, senderAccountId: senderId,
                    message: newMessageText)
                newMessageText = ""
            }
        }
    }
}

#Preview {
    MessageView(
        conversationId: "exampleConversationId",
        messagerName: "Allen the Alien"
    )
    .environmentObject(UserViewModel.mock())
    .environmentObject(MessagingViewModel())
}