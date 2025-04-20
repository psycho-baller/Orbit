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
                        .foregroundColor(.accentColor)
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
    }
}

struct ActionButtonsView: View {
    let onIgnore: () async -> Void
    let onConfirm: () async -> Void

    var body: some View {
        HStack(spacing: 16) {
            Button(action: { Task { await onIgnore() } }) {
                HStack {
                    Image(systemName: "xmark.circle.fill")
                    Text("Ignore")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.red)
                .cornerRadius(12)
                .padding(.horizontal, 1)
            }
            Button(action: { Task { await onConfirm() } }) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Confirm Meetup")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.green)
                .cornerRadius(12)
                .padding(.horizontal, 1)
            }
        }
        .padding(.horizontal, 10)
    }
}

struct ChatDetailView: View {
    let chat: ChatDocument
    let user: UserModel
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var chatVM: ChatViewModel
    @EnvironmentObject var meetupRequestVM: MeetupRequestViewModel
    @StateObject var chatMessageVM: ChatMessageViewModel
    @State private var messageText: String = ""
    @State private var isKeyboardVisible: Bool = false
    @State private var isShowingOptions: Bool = false
    @State private var isShowingMeetupDetails: Bool = false
    @Environment(\.presentationMode) private var presentationMode

    init(chat: ChatDocument, user: UserModel) {
        self.chat = chat
        self.user = user
        _chatMessageVM = StateObject(
            wrappedValue: ChatMessageViewModel(chatId: chat.id, userId: user.id)
        )
    }

    // Determines if the current user is the meetupRequest creator.
    private var isCurrentUserChatCreator: Bool {
        user.id == chat.data.createdByUser?.id
    }

    // The "other user" is the one that is not the current user.
    private var otherUser: UserModel? {
        isCurrentUserChatCreator ? chat.data.otherUser : chat.data.createdByUser
    }

    // Check if the meetupRequest creator (requestor) has sent any message in this chat.
    private var didRequestorSendMessage: Bool {
        chatMessageVM.messages.contains(where: {
            (message: ChatMessageDocument) in
            message.data.sentByUser?.id
                == chat.data.meetupRequest?.createdByUser?.id
        })
    }

    var body: some View {
        ZStack {
            // The dark background covers the entire screen.
            ColorPalette.background(for: colorScheme)

            // The main content: header and messages scroll view.
            VStack {
                ScrollViewReader { scrollProxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(chatMessageVM.messages, id: \.id) {
                                message in
                                MessageBubbleView(message: message)
                            }
                            // Add extra space at the bottom and assign an id for scrolling.
                            Color.clear.frame(height: 50).id("bottom")
                        }
                    }
                    .padding()
                    // When the keyboard is shown, scroll to the last message.
                    .onReceive(
                        NotificationCenter.default.publisher(
                            for: UIResponder.keyboardWillShowNotification)
                    ) { _ in
                         DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation {
                                scrollProxy.scrollTo("bottom", anchor: .bottom)
                            }
                        }
                    }
                    // When the keyboard is hidden, also scroll to the last message.
                    .onReceive(
                        NotificationCenter.default.publisher(
                            for: UIResponder.keyboardWillHideNotification)
                    ) { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation {
                                scrollProxy.scrollTo("bottom", anchor: .bottom)
                            }
                        }
                    }
                    // When messages update, scroll to the last one.
                    .onChange(of: chatMessageVM.messages) {
                        oldMessages, newMessages in
                        withAnimation {
                            scrollProxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                    //                    .padding(.horizontal)
                }
                Spacer()
            }

            // Overlay: Floating action buttons and chat text box.
            VStack {
                Spacer()
                if !isKeyboardVisible {
                    if let meetupCreatorId = chat.data.meetupRequest?
                        .createdByUser?
                        .id,
                        user.id == meetupCreatorId,
                        chat.data.meetupRequest?.status != .filled
                    {
                        ActionButtonsView(
                            onIgnore: { await ignoreChat() },
                            onConfirm: { await confirmMeetup() }
                        )
                        .padding(.horizontal, 24)
                    } else if chat.data.meetupConfirmed {
                        Text("Meetup confirmed!")
                            .foregroundColor(.white)
                    }
                }
                ChatTextBox(message: $messageText, onSend: sendMessage)
            }
            //            NavigationLink(
            //                destination: {
            //                    Group {
            //                        if let other = otherUser,
            //                            let meetupRequest = chat.data.meetupRequest
            //                        {
            //                            // Pass the same user and same logic flag (didRequestorSendMessage)
            //                            MeetupDetailsInsideChat(
            //                                user: other,
            //                                meetupRequest: .mock(data: meetupRequest),
            //                                showFullDetails: didRequestorSendMessage)
            //                        } else {
            //                            EmptyView()
            //                        }
            //                    }
            //                }, isActive: $isShowingMeetupDetails
            //            ) {
            //                EmptyView()
            //            }
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: UIResponder.keyboardWillShowNotification)
        ) { _ in
            isKeyboardVisible = true
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: UIResponder.keyboardWillHideNotification)
        ) { _ in
            isKeyboardVisible = false
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()

        .sheet(isPresented: $isShowingMeetupDetails) {
            if let other = otherUser,
                let meetupRequest = chat.data.meetupRequest
            {
                // Pass the same user and same logic flag (didRequestorSendMessage)
                MeetupDetailsInsideChat(
                    user: other,
                    meetupRequest: .mock(data: meetupRequest),
                    showFullDetails: didRequestorSendMessage)
            } else {
                EmptyView()
            }
        }
        .toolbar {

            ToolbarItem(placement: .navigationBarLeading) {

                HStack(spacing: 8) {
                    Button(action: {
                        // Dismiss or pop the view.
                        // For example, using an environment presentationMode:
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.accentColor)
                    }
                    Button(action: {
                        // go to the meetup details
                        isShowingMeetupDetails = true
                    }) {
                        if let other = otherUser {
                            if didRequestorSendMessage {
                                // Detailed view: Show profile picture and full name (first + last).
                                AsyncImage(
                                    url: URL(
                                        string: other.profilePictureUrl ?? "")
                                ) { image in
                                    image.resizable()
                                        .frame(width: 32, height: 32)
                                        .clipShape(Circle())
                                } placeholder: {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 32, height: 32)
                                        .clipShape(Circle())
                                }
                                Text(
                                    "\(other.firstName) \(other.lastName ?? "")"
                                )
                                .font(.headline)
                                .foregroundColor(.accentColor)
                            } else {
                                // Simple view: Show only the username.
                                Text(other.username)
                                    .font(.headline)
                                    .foregroundColor(.accentColor)
                            }
                            Image(systemName: "chevron.right")
                                .font(.system(size: 10))
                                .padding(.leading, 5)
                        }
                    }
                }
            }

            // Trailing: Icons for call, video, etc.
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // open up a bottom sheet of options like blocking/reporting and of course a dismiss to remove that bottom sheet of options
                    isShowingOptions.toggle()
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.accentColor)
                }
            }
        }
        .confirmationDialog(
            "Options", isPresented: $isShowingOptions, titleVisibility: .visible
        ) {
            Button("Block User", role: .destructive) {
                // Handle block action.
            }
            Button("Report User", role: .destructive) {
                // Handle report action.
            }
            Button("Dismiss", role: .cancel) {}
        }
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
        NavigationStack {
            ChatDetailView(chat: .mock(), user: .mock2())
                .environmentObject(UserViewModel.mock())
                .accentColor(ColorPalette.accent(for: colorScheme))
        }
    }
#endif
