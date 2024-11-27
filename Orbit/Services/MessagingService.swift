//
//  MessagingService.swift
//  Orbit
//
//  Created by Jessy Tseng on 2024-10-29.
//

@preconcurrency import Appwrite
import Foundation

protocol MessagingServiceProtocol {
    func createConversation(_ conversation: ConversationModel) async throws
        -> ConversationDocument
    func createMessage(_ message: MessageModel) async throws -> MessageDocument
    func getMessages(_ conversationId: String, _ numOfMessages: Int)
        async throws -> [MessageDocument]
    func getParticipants(for conversationId: String) async throws -> [String]
<<<<<<< HEAD
    func subscribeToMessages(
        conversationId: String?,
        onNewMessage: @escaping (MessageDocument) -> Void) async throws
    func unsubscribeFromMesages() async
    func markMessagesRead(conversationId: String) async throws
=======
    func subscribeToInboxMessages(
        onNewMessage: @escaping (MessageDocument) -> Void) async throws
    func unsubscribeFromInboxMessages() async
    func subscribeToMessages(
        conversationId: String,
        onNewMessage: @escaping (MessageDocument) -> Void) async throws

    func unsubscribeFromMessages() async
    func markMessagesRead(conversationId: String, currentAccountId: String)
        async throws
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
}

class MessagingService: MessagingServiceProtocol {
    private var appwriteService: AppwriteService = AppwriteService.shared
<<<<<<< HEAD
    private var subscription: RealtimeSubscription?
=======
    private var inboxSubscription: RealtimeSubscription?
    private var messagesSubscription: RealtimeSubscription?
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac

    func createConversation(_ conversation: ConversationModel) async throws
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

<<<<<<< HEAD
    func createMessage(_ message: MessageModel) async throws -> MessageDocument
    {
=======
    func createMessage(_ message: MessageModel) async throws -> MessageDocument {
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
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

<<<<<<< HEAD
    func subscribeToMessages(
        conversationId: String? = nil,
        onNewMessage: @escaping (MessageDocument) -> Void
    ) async throws {

        subscription = try await AppwriteService.shared.realtime2.subscribe(
            channels: [
                "databases.\(AppwriteService.shared.databaseId).collections.messages.documents"
            ]
        ) { event in
            print("Received event: \(event)")
            Task {
                print("MessagingService - Received event: \(event)")
                if let payload = event.payload {
                    do {
                        if let documentId = payload["$id"] as? String {

                            let document = try await self.appwriteService
                                .databases.getDocument(
                                    databaseId: self.appwriteService.databaseId,
                                    collectionId: self.appwriteService
                                        .COLLECTION_ID_MESSAGES,
                                    documentId: documentId,
                                    nestedType: MessageModel.self
                                )
                            
                            onNewMessage(document)
                            /*
                            if conversationId != nil {
                                if document.data.conversationId == conversationId {
=======
    func subscribeToInboxMessages(
        onNewMessage: @escaping (MessageDocument) -> Void
    ) async throws {

        inboxSubscription = try await AppwriteService.shared.realtime2
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
            try await inboxSubscription?.close()
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

        messagesSubscription = try await AppwriteService.shared.realtime2
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
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
                                    print(
                                        "MessagingService - New Message for \(conversationId)"
                                    )
                                    onNewMessage(document)
                                }
<<<<<<< HEAD
                            } else {
                                onNewMessage(document)
                            } */
                          
                            
                        }
                        print(
                            "Subscribed to realtime messsages for conversation: \(conversationId ?? "some conversation")"
                        )
                    } catch {
                        print(
                            "Failed to decode message: \(error.localizedDescription)"
                        )
                    }
                }
            }
        }
    }

    func unsubscribeFromMesages() async {
        do {
            try await subscription?.close()
            subscription = nil
        } catch {
            print(
                "Failed to unscubscirbe from real time messages: \(error.localizedDescription)"
=======

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
            try await messagesSubscription?.close()
            messagesSubscription = nil
        } catch {
            print(
                "MessagingService - Failed to unsubscribe from real time messages: \(error.localizedDescription)"
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
            )
        }
    }

<<<<<<< HEAD
    func markMessagesRead(conversationId: String) async throws {  //get all messages in the particular conversation that are marked as isRead = false
=======
    func markMessagesRead(conversationId: String, currentAccountId: String)
        async throws
    {  //get all messages in the particular conversation that are marked as isRead = false
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
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

<<<<<<< HEAD
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
=======
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

>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
        }

    }

}
