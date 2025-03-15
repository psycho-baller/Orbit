//
//  ChatMessageViewModel.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-03-15.
//

import SwiftUI

@MainActor
class ChatMessageViewModel: ObservableObject {
    @Published var messages: [ChatMessageDocument] = []
    @Published var isLoading = false
    @Published var error: String?

    private var chatMessageService: ChatMessageServiceProtocol =
        ChatMessageService()
    private let chatId: String

    init(chatId: String) {
        self.chatId = chatId
        Task {
            await fetchMessages()
        }
    }

    /// Fetch all messages for this chat
    func fetchMessages() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let fetchedMessages =
                try await chatMessageService.listMessagesForChat(
                    chatId: chatId, queries: nil)
            self.messages = fetchedMessages
        } catch {
            self.error = error.localizedDescription
            print(
                "ChatMessageViewModel - fetchMessages: Error: \(error.localizedDescription)"
            )
        }
    }

    /// Send a new message
    func sendMessage(message: ChatMessageModel) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let savedMessage = try await chatMessageService.createMessage(
                message: message)
            self.messages.append(savedMessage)
        } catch {
            self.error = error.localizedDescription
            print(
                "ChatMessageViewModel - sendMessage: Error: \(error.localizedDescription)"
            )
        }
    }

    /// Mark a message as read
    func markMessageAsRead(_ message: ChatMessageDocument) async {
        guard !(message.data.isRead ?? true) else { return }

        isLoading = true
        defer { isLoading = false }

        var updatedMessage = message.data
        updatedMessage.isRead = true

        do {
            let updatedDocument = try await chatMessageService.createMessage(
                message: updatedMessage)
            if let index = messages.firstIndex(where: {
                $0.id == updatedDocument.id
            }) {
                messages[index] = updatedDocument
            }
        } catch {
            self.error = error.localizedDescription
            print(
                "ChatMessageViewModel - markMessageAsRead: Error: \(error.localizedDescription)"
            )
        }
    }

    /// Delete a message
    func deleteMessage(_ message: ChatMessageDocument) async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await chatMessageService.deleteMessage(messageId: message.id)
            self.messages.removeAll { $0.id == message.id }
        } catch {
            self.error = error.localizedDescription
            print(
                "ChatMessageViewModel - deleteMessage: Error: \(error.localizedDescription)"
            )
        }
    }

    #if DEBUG
        static func mock() -> ChatMessageViewModel {
            let messageVM = ChatMessageViewModel(chatId: "chat-123")
            messageVM.messages = [ChatMessageDocument.mock()]
            return messageVM
        }
    #endif
}
