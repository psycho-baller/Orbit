//
//  MessageDetailView.swift
//  Orbit
//
//  Created by Nathaniel D'Orazio on 2025-03-09.
//

import SwiftUI
import Foundation

struct MessageDetailView: View {
    let request: ChatRequestDocument
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var chatRequestVM: ChatRequestViewModel
    @EnvironmentObject var userVM: UserViewModel
    @State private var messageText = ""
    @State private var messages: [ChatMessageModel] = []
    @State private var senderName: String = "Unknown"
    @StateObject private var chatMessageVM: ChatMessageViewModel

    
    init(request: ChatRequestDocument) {
        self.request = request
        _chatMessageVM = StateObject(wrappedValue: ChatMessageViewModel(chatId: request.id))
    }
    
    var body: some View {
        ZStack {
            Color.blue.opacity(0.9).ignoresSafeArea()
            
            VStack(spacing: 0) {
                ChatProfileTitle(messagerName: senderName, isInMessageView: true)
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(messages, id: \ .id) { message in
                            MessageBubble(
                                message: message.content,
                                isFromSender: message.sentByUser?.id == userVM.currentUser?.id,
                                timestamp: message.createdAtDate != nil
                                            ? DateFormatterUtility.formatForDisplay(message.createdAtDate!)
                                            : "Unknown Time"
                            )
                        }
                    }
                    .padding()
                }
                
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        Button(action: acceptRequest) {
                            Text("Accept")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        Button(action: denyRequest) {
                            Text("Deny")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)

                    HStack(spacing: 12) {
                        TextField("Type a message...", text: $messageText)
                            .padding(10)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(20)

                        Button(action: sendMessage) {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.white)
                        }
                        .disabled(messageText.isEmpty)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                .background(Color.black.opacity(0.2))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchMessages()
            fetchSenderName()
        }
    }

    private func fetchSenderName() {
        Task {
            senderName = userVM.getUserName(from: request.data.senderAccountId)
        }
    }
    
    private func fetchMessages() {
        Task {
            do {
                let fetchedMessages = try await chatMessageVM.fetchMessages()
                DispatchQueue.main.async {
                    self.messages = fetchedMessages
                }
            } catch {
                print("Failed to fetch messages: \(error.localizedDescription)")
            }
        }
    }



    private func acceptRequest() {
        print("Request accepted")
    }

    private func denyRequest() {
        print("Request denied")
    }

    private func sendMessage() {
        print("Sending message: \(messageText)")
        messageText = ""
    }
}

struct MessageBubble: View {
    let message: String
    let isFromSender: Bool
    let timestamp: String  // Pass in a formatted timestamp as a string

    var body: some View {
        HStack {
            if isFromSender { Spacer() } // Align sender's messages to the right
            
            VStack(alignment: .leading, spacing: 4) {
                Text(message)
                    .padding()
                    .background(isFromSender ? Color.green : Color.gray.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(20)

                Text(timestamp)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }

            if !isFromSender { Spacer() } // Align received messages to the left
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }

    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    MessageDetailView(request: .mock(data: .mock()))
        .environmentObject(ChatRequestViewModel.mock())
        .environmentObject(UserViewModel.mock())
}
