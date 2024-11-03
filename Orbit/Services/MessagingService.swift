//
//  MessagingService.swift
//  Orbit
//
//  Created by Jessy Tseng on 2024-10-29.
//

import Foundation
import Appwrite

protocol MessagingServiceProtocol {
    func createConversation(_ conversation: ConversationModel) async throws -> ConversationDocument
    func createMessage(_ message: MessageModel) async throws -> MessageDocument
    func getMessages(conversationId: String, numOfMessages: Int) async throws -> [MessageDocument]
}

class MessagingService: MessagingServiceProtocol {
    private let appwriteService: AppwriteService = AppwriteService.shared
    
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

    func getMessages(conversationId: String, numOfMessages: Int = 100) async throws -> [MessageDocument] {
        
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
    
}
