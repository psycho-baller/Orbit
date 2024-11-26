//
//  MessagingViewModel.swift
//  Orbit
//
//  Created by Jessy Tseng on 2024-11-02.
//

@preconcurrency import Appwrite
import Appwrite
import Foundation
import SwiftUI

class MessagingViewModel: ObservableObject {
    private var messagingService: MessagingServiceProtocol = MessagingService()
    private var userManagementService: UserManagementServiceProtocol =
        UserManagementService()
    private var subscription: RealtimeSubscription?
    @Published var conversations: [ConversationDetailModel] = []
    @Published var messages: [MessageDocument] = []
    @Published var lastMessageId: String? = nil
    var lastMessageld: Binding<String?> {
        Binding(
            get: { self.lastMessageId },
            set: { self.lastMessageId = $0 }
        )
    }

    @MainActor
    func getConversations(_ accountId: String) async -> [String] {
        do {
            if let userModel = try await userManagementService.getUser(
                accountId)
            {
                if let conversations = userModel.data.conversations {
                    return conversations
                }
            }
            throw NSError(domain: "UsersNotFound: \"\(accountId)\"", code: 404)
        } catch {
            print(
                "MessagingViewModel - getConversations failed \(error.localizedDescription)"
            )
            return []
        }
    }

    @MainActor
    func createConversation(_ participants: [String]) async {
        do {
            // Create entry in conversation table
            let conversationData = ConversationModel(participants: participants)
            let conversationEntry =
                try await messagingService.createConversation(conversationData)

            // Add conversation id to users
            for accountId in participants {
                if let userModel = try await userManagementService.getUser(
                    accountId)
                {
                    if let conversations = userModel.data.conversations {
                        var newConversations = conversations
                        newConversations.append(conversationEntry.id)
                        let newUserModel = userModel.data.update(
                            conversations: newConversations
                        )
                        try await userManagementService.updateUser(
                            accountId: accountId, updatedUser: newUserModel)
                    }
                }
            }
        } catch {
            print(
                "MessagingViewModel - createConversation failed \(error.localizedDescription)"
            )
        }
    }

    @MainActor
    func createMessage(
        conversationId: String, senderAccountId: String, message: String
    ) async {
        let newMessage = MessageModel(
            conversationId: conversationId,
            senderAccountId: senderAccountId,
            message: message
        )
        do {
            let createdMessage = try await messagingService.createMessage(newMessage)
            
            DispatchQueue.main.async {
                self.messages.append(createdMessage)
                self.messages.sort {$0.createdAt < $1.createdAt}
                self.lastMessageId = createdMessage.id
            }
        } catch {
            print(
                "MessagingViewModel - createMessage failed \(error.localizedDescription)"
            )
        }
    }

    @MainActor
    func getMessages(_ conversationId: String, _ numOfMessages: Int = 100) async
        -> [MessageDocument]
    {
        print("Loading messages for conversation ID: \(conversationId)")
        do {
            messages = try await messagingService.getMessages(
                conversationId, numOfMessages)
            if let lastMessage = messages.last {
                lastMessageId = lastMessage.id
            }
            return messages
        } catch {
            print(
                "MessagingViewModel - createMessage failed \(error.localizedDescription)"
            )
            return []
        }
    }

    @MainActor
    func getConversationDetails(_ accountId: String) async
        -> [ConversationDetailModel]
    {
        print("Getting conversations for user: \(accountId)")

        let conversationIds = await getConversations(accountId)
        print("Fetched conversation IDs: \(conversationIds)")

        let conversationDetails = await withTaskGroup(
            of: ConversationDetailModel?.self
        ) { group in
            for conversationId in conversationIds {
                group.addTask {
                    await self.fetchConversationDetail(
                        accountId: accountId, conversationId: conversationId)
                }
            }

            var results: [ConversationDetailModel] = []
            for await detail in group {
                if let detail = detail {
                    results.append(detail)
                }
            }
            return results
        }
        return conversationDetails.sorted { $0.timestamp > $1.timestamp }
    }

    @MainActor
    private func fetchConversationDetail(
        accountId: String, conversationId: String
    ) async -> ConversationDetailModel? {
        do {
            let participants = try await messagingService.getParticipants(
                for: conversationId)
            guard
                let otherParticipantId = participants.first(where: {
                    $0 != accountId
                })
            else { return nil }

            let messagerName = await getParticipantName(otherParticipantId)
            let messages = try await messagingService.getMessages(
                conversationId, 100)
            guard
                let lastMessage = messages.max(by: {
                    $0.createdAt < $1.createdAt
                })
            else { return nil }

            return ConversationDetailModel(
                id: conversationId,
                messagerName: messagerName,
                lastMessage: lastMessage.data.message,
                timestamp: formatTimestamp(lastMessage.createdAt),
                isRead: lastMessage.data.isRead ?? false
            )
        } catch {
            print("Failed to process conversation \(conversationId): \(error)")
            return nil
        }
    }

    private func getParticipantName(_ participantId: String) async -> String {
        do {
            if let user = try await userManagementService.getUser(participantId)
            {
                return user.data.name
            }
        } catch {
            print(
                "Failed to get participant name for ID \(participantId): \(error)"
            )
        }
        return "Unknown"
    }

    func formatTimestamp(_ timestamp: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime, .withFractionalSeconds,
        ]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        if let date = formatter.date(from: timestamp) {
            let displayFormatter = DateFormatter()
            displayFormatter.timeZone = TimeZone.current
            displayFormatter.dateStyle = .short
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }

        return "Unknown"
    }

    @MainActor
    func subscribeToMessages(
        conversationId: String,
        onNewMessage: @escaping (MessageDocument) -> Void
    ) async {
        do {
            try await messagingService.subscribeToMessages(
                conversationId: conversationId,
                onNewMessage: { newMessage in
                    DispatchQueue.main.async {
                        onNewMessage(newMessage)  // Safely call the optional closure
                    }
                }
            )
            print(
                "MessagingViewModel - Subscribed to real-time messages for conversation: \(conversationId)"
            )

        } catch {
            print(
                "MessagingViewModel - Failed to subscribe to real-time messages: \(error.localizedDescription)"
            )
        }

    }

    @MainActor
    func unsubscribeFromMessages() async {
        await messagingService.unsubscribeFromMessages()
    }
    
    @MainActor
    func subscribeToInboxMessages(
        conversationId: String,
        onNewMessage: @escaping (MessageDocument) -> Void
    ) async {
        do {
            try await messagingService.subscribeToInboxMessages(
                conversationId: conversationId,
                onNewMessage: { newMessage in
                    DispatchQueue.main.async {
                        onNewMessage(newMessage)  // Safely call the optional closure
                    }
                }
            )
            print(
                "MessagingViewModel - Subscribed to real-time messages for conversation Inbox: \(conversationId)"
            )

        } catch {
            print(
                "MessagingViewModel - Failed to subscribe to real-time messages for Inbox: \(error.localizedDescription)"
            )
        }

    }
    
    @MainActor
    func unsubscribeFromInboxMessages() async {
        await messagingService.unsubscribeFromInboxMessages()
    }

    /// Initializes the inbox: Fetches conversations and subscribes to new messages
    @MainActor
    func initializeInbox(
        for userId: String?,
        completion: @escaping ([ConversationDetailModel]) -> Void
    ) async {
        guard let userId = userId else {
            print("User ID not found")
            return
        }

        print("Fetching conversations for user ID: \(userId)")
        var fetchedConversations = await getConversationDetails(userId)
        fetchedConversations.sort {$0.timestamp > $1.timestamp}
        self.conversations = fetchedConversations
        completion(fetchedConversations)

        await subscribeToInboxMessages(
            conversationId: "",
            onNewMessage: { newMessage in
                DispatchQueue.main.async{
                    print("MessagingViewModel - Received new message for Inbox: \(newMessage.data.message)")
                    
                    if let index = self.conversations.firstIndex(where: {$0.id == newMessage.data.conversationId}) {
                        var updatedConversation = self.conversations[index]
                        updatedConversation.update(with: newMessage)
                        updatedConversation.timestamp = self.formatTimestamp(newMessage.createdAt)
                                          
                        self.conversations.remove(at: index)
                        self.conversations.insert(updatedConversation, at: 0)
                    } else {
                        Task{
                            if let newConversation = await self.fetchConversationDetail(accountId: userId, conversationId: newMessage.data.conversationId) {
                                DispatchQueue.main.async {
                                self.conversations.insert(newConversation, at: 0)
                                }
                            }
                        }
                                        
                    }

                    /*self.conversations = self.conversations.map { conversation in
                        var mutableConversation = conversation  // Create a mutable copy
                        if mutableConversation.id == newMessage.data.conversationId
                        {
                         
                            mutableConversation.update(with: newMessage)  // Mutate the copy
                            mutableConversation.timestamp = self.formatTimestamp(newMessage.createdAt)
                        }
                        return mutableConversation
                    } */
                    
                }
             
            })
    }

    @MainActor
    func markMessagesRead(conversationId: String, currentAccountId: String) async {
        do {
            try await messagingService.markMessagesRead(
                conversationId: conversationId, currentAccountId: currentAccountId)
            print(
                "MessagingViewModel - marked all messages as read in conversation \(conversationId)"
            )
        } catch {
            print(
                "MessagingViewModel - failed to mark messages as read: \(error.localizedDescription)"
            )
        }
    }

}
