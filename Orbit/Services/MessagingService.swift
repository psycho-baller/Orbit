//
//  MessagingService.swift
//  Orbit
//
//  Created by Jessy Tseng on 2024-10-29.
//

import Foundation
@preconcurrency import Appwrite

protocol MessagingServiceProtocol {
    func createConversation(_ conversation: ConversationModel) async throws -> ConversationDocument
    func createMessage(_ message: MessageModel) async throws -> MessageDocument
    func getMessages(_ conversationId: String, _ numOfMessages: Int) async throws -> [MessageDocument]
    func getParticipants(for conversationId: String) async throws -> [String]
    func subscribeToMessages(conversationId: String, onNewMessage: @escaping (MessageDocument) -> Void) async throws
    func unsubscribeFromMesages() async
    func markMessagesRead(conversationId: String) async throws
}

class MessagingService: MessagingServiceProtocol {
    private var appwriteService: AppwriteService = AppwriteService.shared
    private var subscription: RealtimeSubscription?
    
    func createConversation(_ conversation: ConversationModel) async throws -> ConversationDocument{
        let document = try await appwriteService.databases.createDocument<ConversationModel>(
                    databaseId: appwriteService.databaseId,
                    collectionId: appwriteService.COLLECTION_ID_CONVERSATIONS,
                    documentId: ID.unique(),
                    data: conversation.toJson(),
                    permissions: nil,
                    nestedType: ConversationModel.self
                )
        print("created conversation: \(document)")
        return document;
    }

    func createMessage(_ message: MessageModel) async throws -> MessageDocument{
        let document = try await appwriteService.databases.createDocument<MessageModel>(
                    databaseId: appwriteService.databaseId,
                    collectionId: appwriteService.COLLECTION_ID_MESSAGES,
                    documentId: ID.unique(),
                    data: message.toJson(),
                    permissions: nil,
                    nestedType: MessageModel.self
                )
        print("created message: \(document)")
        return document;
    }

    func getMessages(_ conversationId: String, _ numOfMessages: Int) async throws -> [MessageDocument] {
        
        let queries = [
            Query.equal("conversationId", value: conversationId),
            Query.orderAsc("createdAt"),
            Query.limit(numOfMessages)
        ]
        
        let messages = try await appwriteService.databases.listDocuments<MessageModel>(
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
    
    func subscribeToMessages(conversationId: String, onNewMessage: @escaping (MessageDocument) -> Void) async throws{
        
        subscription = try await AppwriteService.shared.realtime2.subscribe(
                channels: [
                    "databases.\(AppwriteService.shared.databaseId).collections.messages.documents"
                ]
            ) {event in
                print("Received event: \(event)")
                Task{
                    print("MessagingService - Received event: \(event)")
                    if let payload = event.payload {
                        do {
                            if let documentId = payload["$id"] as? String{
                                
                                let document = try await self.appwriteService.databases.getDocument(
                                    databaseId: self.appwriteService.databaseId,
                                    collectionId: self.appwriteService.COLLECTION_ID_MESSAGES,
                                    documentId: documentId,
                                    nestedType: MessageModel.self
                                )
                                
                                if document.data.conversationId == conversationId {
                                    print("MessagingService - New Message for \(conversationId)")
                                    onNewMessage(document)
                                }
                            }
                            print("Subscribed to realtime messsages for conversation: \(conversationId)")
                        } catch {
                            print("Failed to decode message: \(error.localizedDescription)")
                        }
                    }
                }
            }
    }
    
    func unsubscribeFromMesages() async {
        do{
            try await subscription?.close()
            subscription = nil
        } catch {
            print("Failed to unscubscirbe from real time messages: \(error.localizedDescription)")
        }
    }
    
    func markMessagesRead(conversationId: String) async throws {  //get all messages in the particular conversation that are marked as isRead = false
        let queries = [
            Query.equal("conversationId", value: conversationId),
            Query.equal("isRead", value: false)
        ]
        
        let messages = try await appwriteService.databases.listDocuments<MessageModel>(  //getting messages based on queries
            databaseId: appwriteService.databaseId,
            collectionId: appwriteService.COLLECTION_ID_MESSAGES,
            queries: queries,
            nestedType: MessageModel.self
        )
        
        for message in messages.documents {
            
            let updatedMessage = MessageModel(
                conversationId: message.data.conversationId,
                senderAccountId: message.data.senderAccountId,
                message: message.data.message,
                createdAt: message.data.createdAt,
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
