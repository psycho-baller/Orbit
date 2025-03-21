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
    @EnvironmentObject var chatVM: ChatViewModel
    @EnvironmentObject var meetupRequestVM: MeetupRequestViewModel
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
                .onChange(of: chatMessageVM.messages) {
                    oldMessages, newMessages in
                    if let lastMessage = newMessages.last {
                        withAnimation {
                            scrollProxy.scrollTo(
                                lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }

            if let meetupCreatorId = chat.data.meetupRequest?.createdByUser?.id,
                user.id != meetupCreatorId
            {
                HStack(spacing: 16) {
                    Button(action: { Task { await ignoreChat() } }) {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                            Text("Ignore")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.red)
                        .cornerRadius(16)
                    }
                    Button(action: { Task { await confirmMeetup() } }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Confirm Meetup")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.green)
                        .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 24)
                //            .padding(.vertical, 2)
            } else if chat.data.meetupRequest?.status != .filled {
                Text("Meetup confirmed!")
            }

            HStack {
                TextField("Type a message...", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.accentColor)
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

    /// Confirm the meetup: mark the current chat as confirmed and archive other chats.
    func confirmMeetup() async {
        await chatVM.confirmMeetup(for: chat)
        // make the meetup request 'filled'
        if var meetupRequest = chat.data.meetupRequest {
            meetupRequest.status = .filled
            await meetupRequestVM.updateMeetup(meetupRequest)
        }
    }

    /// Ignore (archive) this chat. For this design, you might choose to simply delete it.
    func ignoreChat() async {
        //        await chatVM.deleteChat(chat)
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
