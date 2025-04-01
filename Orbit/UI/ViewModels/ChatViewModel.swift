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
    func getChatDocument(chatId: String) async -> ChatDocument? {
        isLoading = true
        defer { isLoading = false }

        // First check if it's already in 'chats'
        if let chatDoc = chats.first(where: { $0.id == chatId }) {
            return chatDoc
        }

        do {
            let chatDoc = try await chatService.getChat(chatId: chatId)
            return chatDoc
        } catch {
            self.error = error.localizedDescription
            print(
                "ChatViewModel - getChatDocument: Error: \(error.localizedDescription)"
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

    // MARK: - Meetup Confirmation & Chat Archiving

    /// Confirm a meetup for the given chat.
    /// This marks the selected chat as confirmed and then archives (removes) all other chats
    /// for the same meetup request.
    func confirmMeetup(for chat: ChatDocument) async {
        // 1. Update the selected chat to be confirmed.
        var updatedChatModel = chat.data
        updatedChatModel.meetupConfirmed = true
        if let confirmedChat = await chatService.updateChat(
            chatId: chat.id, updatedChat: updatedChatModel)
        {
            print(
                "Meetup confirmed for chat \(confirmedChat.id) and other chats archived."
            )
            if let index = chats.firstIndex(where: {
                $0.id == confirmedChat.id
            }) {
                chats[index] = confirmedChat
            }
        }
        // 2. Archive (remove) all other chats for the same meetup request.
        //        try await archiveOtherChats(for: confirmedChat)

        // Optionally, update the related meetup request to mark it as filled.
        // This can be done via a separate MeetupRequestService.
    }

    /// Archive (remove) all chats related to the same meetup request except the confirmed one.
    func archiveOtherChats(for confirmedChat: ChatDocument) async throws {
        guard let targetMeetupId = confirmedChat.data.meetupRequest?.id else {
            return
        }

        // For each chat that belongs to the same meetup request and is not the confirmed one,
        // you may choose to update the backend (if needed) or simply remove it from the local list.
        let chatsToArchive = chats.filter { chat in
            chat.id != confirmedChat.id
                && chat.data.meetupRequest?.id == targetMeetupId
        }

        // Remove them from the local array.
        chats.removeAll { chat in
            chat.id != confirmedChat.id
                && chat.data.meetupRequest?.id == targetMeetupId
        }

        // Optionally, if you need to update them on the backend (e.g. to mark them as archived)
        // you could iterate over chatsToArchive and perform an update.
        // For this design, the absence of a confirmed chat implies they are archived.
    }

    #if DEBUG
        static func mock() -> ChatViewModel {
            let chatVM = ChatViewModel()
            chatVM.chats = [ChatDocument.mock()]
            return chatVM
        }
    #endif
}
