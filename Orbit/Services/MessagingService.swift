//
//  MessagingService.swift
//  Orbit
//
//  Created by Jessy Tseng on 2024-10-29.
//

@preconcurrency import Appwrite
import Foundation

protocol MessagingServiceProtocol {
    func findOrCreateConversation(_ conversation: ConversationModel)
        async throws
        -> ConversationDocument
    func createMessage(_ message: MessageModel) async throws -> MessageDocument
    func getMessages(_ conversationId: String, _ numOfMessages: Int)
        async throws -> [MessageDocument]
    func getParticipants(for conversationId: String) async throws -> [String]
    func subscribeToInboxMessages(
        onNewMessage: @escaping (MessageDocument) -> Void) async throws
    func unsubscribeFromInboxMessages() async
    func subscribeToMessages(
        conversationId: String,
        onNewMessage: @escaping (MessageDocument) -> Void) async throws

    func unsubscribeFromMessages() async
    func markMessagesRead(conversationId: String, currentAccountId: String)
        async throws
    func conversationExists(_ conversationId: String) async throws -> Bool
}

class MessagingService: MessagingServiceProtocol {
    private var appwriteService: AppwriteService = AppwriteService.shared
    private var inboxSubscription: RealtimeSubscription?
    private var messagesSubscription: RealtimeSubscription?

    /// Only call this function within the service. In most cases, we wanna first check if the conversation already exists in the collection before creating a new one
    /// - Parameter conversation: conversation data (basically just the participants)
    private func createConversation(_ conversation: ConversationModel)
        async throws
        -> ConversationDocument
    {
        let document = try await appwriteService.databases.createDocument<
            ConversationModel
        >(
            databaseId: appwriteService.databaseId,
            collectionId: appwriteService.COLLECTION_ID_CONVERSATIONS,
            documentId: ID.unique(),
            data: conversation.toJson(),
            permissions: nil,
            nestedType: ConversationModel.self
        )
        print("created conversation: \(document)")
        return document
    }

    func findOrCreateConversation(
        _ conversation: ConversationModel
    ) async throws -> ConversationDocument {
        let participants = conversation.participants
        // Step 1: Query for existing conversations with the same participants
        let queries = [
            Query.contains("participants", value: participants),
            Query.limit(1),  // Limit to one match
        ]

        // Attempt to find an existing conversation
        let existingConversations = try await appwriteService.databases
            .listDocuments<
                ConversationModel
            >(
                databaseId: appwriteService.databaseId,
                collectionId: appwriteService.COLLECTION_ID_CONVERSATIONS,
                queries: queries,
                nestedType: ConversationModel.self
            )

        // Step 2: If an existing conversation is found, return it
        if let existingConversation = existingConversations.documents.first {
            print("Found existing conversation: \(existingConversation)")
            return existingConversation
        }

        // Step 3: If no conversation is found, create a new one
        let newConversation = ConversationModel(
            participants: participants
        )

        let createdConversation = try await createConversation(newConversation)
        print("Created new conversation: \(createdConversation)")
        return createdConversation
    }

    func createMessage(_ message: MessageModel) async throws -> MessageDocument
    {
        let document = try await appwriteService.databases.createDocument<
            MessageModel
        >(
            databaseId: appwriteService.databaseId,
            collectionId: appwriteService.COLLECTION_ID_MESSAGES,
            documentId: ID.unique(),
            data: message.toJson(),
            permissions: nil,
            nestedType: MessageModel.self
        )
        print("created message: \(document)")
        return document
    }

    func getMessages(_ conversationId: String, _ numOfMessages: Int)
        async throws -> [MessageDocument]
    {

        let queries = [
            Query.equal("conversationId", value: conversationId),
            Query.orderAsc("$createdAt"),
            Query.limit(numOfMessages),
        ]

        let messages = try await appwriteService.databases.listDocuments<
            MessageModel
        >(
            databaseId: appwriteService.databaseId,
            collectionId: appwriteService.COLLECTION_ID_MESSAGES,
            queries: queries,
            nestedType: MessageModel.self
        )

        return messages.documents
    }

    func getParticipants(for conversationId: String) async throws -> [String] {

        let document = try await appwriteService.databases.getDocument(
            databaseId: appwriteService.databaseId,
            collectionId: appwriteService.COLLECTION_ID_CONVERSATIONS,
            documentId: conversationId,
            nestedType: ConversationModel.self
        )
        return document.data.participants ?? []
    }

    func subscribeToInboxMessages(
        onNewMessage: @escaping (MessageDocument) -> Void
    ) async throws {

        inboxSubscription = try await AppwriteService.shared.realtime
            .subscribe(
                channels: [
                    "databases.\(AppwriteService.shared.databaseId).collections.messages.documents"
                ]
            ) { event in
                //print("MessagingService - Received event for Inbox: \(event)")
                Task {
                    print(
                        "MessagingService - Received event for Inbox: \(event)")
                    if let payload = event.payload {
                        do {
                            if let documentId = payload["$id"] as? String {

                                let document: MessageDocument? =
                                    try await self.appwriteService
                                    .databases.getDocument(
                                        databaseId: self.appwriteService
                                            .databaseId,
                                        collectionId: self.appwriteService
                                            .COLLECTION_ID_MESSAGES,
                                        documentId: documentId,
                                        nestedType: MessageModel.self
                                    )
                                if let document = document {
                                    onNewMessage(document)
                                }
                            }
                            print(
                                "MessagingService - Subscribed to realtime messsages for conversations in Inbox"
                            )
                        } catch {
                            print(
                                "MessagingService - Failed to decode message: \(error.localizedDescription)"
                            )
                        }
                    }
                }
            }
    }

    func unsubscribeFromInboxMessages() async {
        do {
//            try await inboxSubscription?.close()
            inboxSubscription = nil
        } catch {
            print(
                "MessagingService - Failed to unsubscribe from real time messages for Inbox: \(error.localizedDescription)"
            )
        }
    }

    func subscribeToMessages(
        conversationId: String,
        onNewMessage: @escaping (MessageDocument) -> Void
    ) async throws {

        messagesSubscription = try await AppwriteService.shared.realtime
            .subscribe(
                channels: [
                    "databases.\(AppwriteService.shared.databaseId).collections.messages.documents"
                ]
            ) { event in
                //print("MessagingService - Received event for messages: \(event)")
                Task {
                    print(
                        "MessagingService - Received event for messages: \(event)"
                    )
                    if let payload = event.payload {
                        do {
                            if let documentId = payload["$id"] as? String {

                                let document = try await self.appwriteService
                                    .databases.getDocument(
                                        databaseId: self.appwriteService
                                            .databaseId,
                                        collectionId: self.appwriteService
                                            .COLLECTION_ID_MESSAGES,
                                        documentId: documentId,
                                        nestedType: MessageModel.self
                                    )

                                //onNewMessage(document)

                                if document.data.conversationId
                                    == conversationId
                                {
                                    print(
                                        "MessagingService - New Message for \(conversationId)"
                                    )
                                    onNewMessage(document)
                                }

                            }
                            print(
                                "MessagingService - Subscribed to realtime messsages for conversation: \(conversationId)"
                            )
                        } catch {
                            print(
                                "MessagingService - Failed to decode message: \(error.localizedDescription)"
                            )
                        }
                    }
                }
            }
    }

    func unsubscribeFromMessages() async {
        do {
//            try await messagesSubscription?.close()
            messagesSubscription = nil
        } catch {
            print(
                "MessagingService - Failed to unsubscribe from real time messages: \(error.localizedDescription)"
            )
        }
    }

    func markMessagesRead(conversationId: String, currentAccountId: String)
        async throws
    {  //get all messages in the particular conversation that are marked as isRead = false
        let queries = [
            Query.equal("conversationId", value: conversationId),
            Query.equal("isRead", value: false),
        ]

        let messages = try await appwriteService.databases.listDocuments<
            MessageModel
        >(  //getting messages based on queries
            databaseId: appwriteService.databaseId,
            collectionId: appwriteService.COLLECTION_ID_MESSAGES,
            queries: queries,
            nestedType: MessageModel.self
        )

        for message in messages.documents {

            if message.data.senderAccountId != currentAccountId {
                let updatedMessage = MessageModel(
                    conversationId: message.data.conversationId,
                    senderAccountId: message.data.senderAccountId,
                    message: message.data.message,
                    isRead: true
                )

                try await appwriteService.databases.updateDocument(
                    databaseId: appwriteService.databaseId,
                    collectionId: appwriteService.COLLECTION_ID_MESSAGES,
                    documentId: message.id,
                    data: updatedMessage.toJson())

            }

        }

    }

    func conversationExists(_ conversationId: String) async throws -> Bool {
        do {
            _ = try await appwriteService.databases.getDocument(
                databaseId: appwriteService.databaseId,
                collectionId: appwriteService.COLLECTION_ID_CONVERSATIONS,
                documentId: conversationId,
                nestedType: ConversationModel.self
            )
            return true
        } catch {
            return false
        }
    }

}
