//
//  ChatMessageViewModel.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-03-15.
//

import Appwrite
import SwiftUI

@MainActor
class ChatMessageViewModel: ObservableObject {
    @Published var messages: [ChatMessageDocument] = []
    @Published var isLoading = false
    @Published var error: String?

    private let chatId: String
    private let userId: String?

    private var chatMessageService: ChatMessageServiceProtocol =
        ChatMessageService()
    private var appwriteRealtimeClient = AppwriteService.shared.realtime
    private var realtimeSubscription: RealtimeSubscription?

    init(chatId: String, userId: String? = nil) {
        self.chatId = chatId
        self.userId = userId
        if isPreviewMode {
            self.messages = [
                .mock(data: .mock()),
                .mock(data: .mockOtherUserSent()),
            ]
        } else {
            Task {
                await fetchMessages()
                await subscribeToRealtime()
            }
        }
    }

    deinit {
        Task {
            await unsubscribeFromRealtime()
        }
    }

    /// Subscribes to realtime updates for the messages collection.
    @MainActor
    func subscribeToRealtime() async {
        print(
            "ChatMessageViewModel - subscribeToRealtimeUpdates: Subscribing to real-time updates for messages."
        )
        do {
            realtimeSubscription = try await appwriteRealtimeClient.subscribe(
                channels: [
                    "databases.\(AppwriteService.shared.databaseId).collections.\(chatMessageService.collectionId).documents"
                ]
            ) { event in
                if let payload = event.payload {
                    print("\nReceived real-time update: \(payload)")
                    Task {
                        do {
                            // Convert the payload dictionary into Data
                            //                            let data = try JSONSerialization.data(
                            //                                withJSONObject: payload)
                            //                            let incomingMessage = try JSONDecoder().decode(
                            //                                ChatMessageDocument.self, from: data)
                            // Convert the payload dictionary into Data.
                            let data = try JSONSerialization.data(
                                withJSONObject: payload)
                            // Convert Data back to a dictionary.
                            guard
                                let json = try JSONSerialization.jsonObject(
                                    with: data, options: []) as? [String: Any]
                            else {
                                return
                            }
                            // Use your helper to create a Document (ChatMessageDocument) from the dictionary.
                            let incomingMessage = ChatMessageDocument.from(
                                map: json)
                            // Filter events for the current chat only.
                            if let messageChat = incomingMessage.data.chat,
                                messageChat.id == self.chatId,
                                // filter only the mssages not sent by us
                                incomingMessage.data.sentByUser?.id
                                    != self.userId
                            {
                                print("\nReceived message: \(messageChat)")
                                // Since event.events is an array, use the first event string.
                                if let eventType = event.events?.first {
                                    DispatchQueue.main.async {
                                        print("events: \(eventType)")
                                        if eventType.contains("create") {
                                            self.messages.append(
                                                incomingMessage)
                                        } else if eventType.contains("update") {
                                            if let index = self.messages
                                                .firstIndex(where: {
                                                    $0.id == incomingMessage.id
                                                })
                                            {
                                                self.messages[index] =
                                                    incomingMessage
                                            }
                                        } else if eventType.contains("delete") {
                                            self.messages.removeAll {
                                                $0.id == incomingMessage.id
                                            }
                                        }
                                    }
                                    print(
                                        "ChatMessageViewModel - subscribeToRealtimeUpdates: Received update for message \(incomingMessage.id)."
                                    )
                                }
                            }
                        } catch {
                            print(
                                "ChatMessageViewModel - subscribeToRealtimeUpdates: Error decoding message: \(error.localizedDescription)"
                            )
                        }
                    }
                }
            }
            print(
                "ChatMessageViewModel - subscribeToRealtimeUpdates: Successfully subscribed to real-time updates."
            )
        } catch {
            print(
                "ChatMessageViewModel - subscribeToRealtimeUpdates: Error subscribing to real-time updates: \(error.localizedDescription)"
            )
            self.error = error.localizedDescription
        }
    }

    /// Unsubscribes from realtime updates.
    @MainActor
    func unsubscribeFromRealtime() async {
        do {
            try await realtimeSubscription?.close()
            //            AppwriteService.shared.realtime.unsubscribe(
            //                subscription: subscription)
            realtimeSubscription = nil
            print(
                "ChatMessageViewModel - unsubscribeFromRealtime: Unsubscribed from real-time updates."
            )
        } catch {

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
            let createdMessage = try await chatMessageService.createMessage(
                message: message)
            // update the final element with the data from savedMessage
            messages[messages.count - 1] = createdMessage
        } catch {
            // remove the final element (the mock one)
            messages.popLast()
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
            messageVM.messages = [.mock()]
            return messageVM
        }
    #endif
}
