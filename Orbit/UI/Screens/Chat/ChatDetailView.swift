//
//  ChatDetailView.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-03-14.
//

import SwiftUI

struct ChatDetailView: View {
    let chat: ChatDocument
    let user: UserModel
    @EnvironmentObject var userVM: UserViewModel
    @StateObject var chatMessageVM: ChatMessageViewModel
    @State private var messageText: String = ""

    init(chat: ChatDocument, user: UserModel) {
        self.chat = chat
        self.user = user
        _chatMessageVM = StateObject(
            wrappedValue: ChatMessageViewModel(
                chatId: chat.id, userId: user.id))
    }

    var body: some View {
        VStack {
            ScrollViewReader { scrollProxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(chatMessageVM.messages, id: \.id) { message in
                            MessageBubbleView(message: message)
                        }
                    }
                }
                .padding()
                // When messages update, scroll to the last one.
                .onChange(of: chatMessageVM.messages) { messages in
                    if let lastMessage = messages.last {
                        withAnimation {
                            scrollProxy.scrollTo(
                                lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }

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
    }

    func sendMessage() {
        Task {
            let newMessage = ChatMessageModel(
                sentByUser: user,
                chat: chat.data,
                content: messageText
            )
            messageText = ""
            // Add a mock Document which will be replaced by the actual data once the message gets sent
            chatMessageVM.messages.append(
                ChatMessageDocument.mock(data: newMessage))
            await chatMessageVM.sendMessage(message: newMessage)
        }
    }
}

#if DEBUG
    #Preview {
        @Previewable @Environment(\.colorScheme) var colorScheme

        ChatDetailView(chat: .mock(), user: .mock2())
            .environmentObject(UserViewModel.mock())
            .accentColor(ColorPalette.accent(for: colorScheme))

    }
#endif
