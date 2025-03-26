//
//  ChatDetailView.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-03-14.
//

import SwiftUI

struct ProfileHeaderView: View {
    let chat: ChatDocument

    var body: some View {
        VStack(spacing: 10) {
            // Profile Picture & Username
            HStack {
                Image("profile_pic")  // Replace with actual image
                    .resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.5), lineWidth: 2)
                    )

                VStack(alignment: .leading) {
                    Text("@financegirl_._")
                        .foregroundColor(.cyan)
                        .font(.headline)
                    Text("Christie")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }
                Spacer()
                Image(systemName: "ellipsis")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)

            // Interests
            InterestsView()

            // Bio Section
            VStack(alignment: .leading, spacing: 4) {
                Text("Bio")
                    .foregroundColor(.white.opacity(0.5))
                    .font(.caption)

                Text("Loves money. Spending a lot recently.")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue.opacity(0.5))
                    .cornerRadius(10)
            }
            .padding(.horizontal)

        }
        .padding()
        .background(
            Color.blue.opacity(0.15)
                .blur(radius: 1)
        )
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }
}

// Interests Tag View
struct InterestsView: View {
    var body: some View {
        HStack {
            InterestTag(title: "intrest 1")
            InterestTag(title: "intrest 2")
            InterestTag(title: "wow another intrest")
        }
    }
}

struct InterestTag: View {
    let title: String

    var body: some View {
        Text(title)
            .padding(8)
            .background(Color.blue.opacity(0.3))
            .foregroundColor(.white)
            .cornerRadius(10)
            .font(.caption)
    }
}
struct ActionButtonsView: View {
    var body: some View {
        HStack {
            Button(action: { /* Deny Action */  }) {
                Text("Deny")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .overlay(
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white)
                            .offset(x: -40)
                    )
            }

            Button(action: { /* Accept Action */  }) {
                Text("Accept")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .overlay(
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                            .offset(x: -40)
                    )
            }
        }
        .padding()
    }
}

struct ChatInputBar: View {
    @Binding var messageText: String
    let sendMessage: () -> Void

    var body: some View {
        HStack {
            Button(action: { /* Add Action */  }) {
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.gray.opacity(0.3))
                    .clipShape(Circle())
            }

            ZStack(alignment: .leading) {
                if messageText.isEmpty {
                    Text("Hmm...")
                        .foregroundColor(Color.white.opacity(0.85))
                        .font(.system(size: 15, weight: .bold))
                        .padding(.leading, 12)
                }

                TextField("", text: $messageText)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(20)
            }

            Button(action: sendMessage) {
                Image(systemName: "mic.fill")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.gray.opacity(0.3))
                    .clipShape(Circle())
            }
        }
        .padding()
        .background(Color.darkIndigo)
    }
}

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
            ProfileHeaderView(chat: chat)
                .padding(.bottom, 10)
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
                .padding(.horizontal)
            }
            if let meetupCreatorId = chat.data.meetupRequest?.createdByUser?.id,
                user.id == meetupCreatorId
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
            }

            ActionButtonsView()

            ChatInputBar(messageText: $messageText, sendMessage: sendMessage)
                .padding(.bottom)
        }
        .background(Color.darkIndigo.ignoresSafeArea())
        Button(action: sendMessage) {
            Image(systemName: "paperplane.fill")
                .foregroundColor(.accentColor)
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

// Custom Dark Indigo Color
extension Color {
    static let darkIndigo = Color(
        red: 13 / 255, green: 16 / 255, blue: 48 / 255)
}

#if DEBUG
    #Preview {
        @Previewable @Environment(\.colorScheme) var colorScheme

        ChatDetailView(chat: .mock(), user: .mock2())
            .environmentObject(UserViewModel.mock())
            .accentColor(ColorPalette.accent(for: colorScheme))

    }
#endif
