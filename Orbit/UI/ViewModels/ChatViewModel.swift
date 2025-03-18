//
//  ChatViewModel.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-03-14.
//

import SwiftUI

@MainActor
class ChatViewModel: ObservableObject {
    @Published var chats: [ChatDocument] = []
    @Published var isLoading = false
    @Published var error: String?

    private var chatService: ChatServiceProtocol = ChatService()

    init() {
        if !isPreviewMode {
            Task {
                await fetchChats()
            }
        }
    }

    /// Fetch all chats from the database
    func fetchChats() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let fetchedChats = try await chatService.listChats(queries: nil)
            self.chats = fetchedChats
        } catch {
            self.error = error.localizedDescription
            print(
                "ChatViewModel - fetchChats: Error: \(error.localizedDescription)"
            )
        }
    }

    /// Create a new chat
    func createChat(chat: ChatModel) async -> ChatDocument? {
        isLoading = true
        defer { isLoading = false }

        do {
            let savedChat = try await chatService.createChat(chat: chat)
            self.chats.append(savedChat)
            return savedChat
        } catch {
            self.error = error.localizedDescription
            print(
                "ChatViewModel - createChat: Error: \(error.localizedDescription)"
            )
            return nil
        }
    }

    /// Update an existing chat
    func updateChat(_ chat: ChatDocument) async {
        isLoading = true
        defer { isLoading = false }

        do {
            if let updatedChat = try await chatService.updateChat(
                chatId: chat.id, updatedChat: chat.data
            ), let index = chats.firstIndex(where: { $0.id == updatedChat.id })
            {
                chats[index] = updatedChat
            }
        } catch {
            self.error = error.localizedDescription
            print(
                "ChatViewModel - updateChat: Error: \(error.localizedDescription)"
            )
        }
    }

    /// Delete a chat
    func deleteChat(_ chat: ChatDocument) async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await chatService.deleteChat(chatId: chat.id)
            self.chats.removeAll { $0.id == chat.id }
        } catch {
            self.error = error.localizedDescription
            print(
                "ChatViewModel - deleteChat: Error: \(error.localizedDescription)"
            )
        }
    }

    #if DEBUG
        static func mock() -> ChatViewModel {
            let chatVM = ChatViewModel()
            chatVM.chats = [ChatDocument.mock()]
            return chatVM
        }
    #endif
}
