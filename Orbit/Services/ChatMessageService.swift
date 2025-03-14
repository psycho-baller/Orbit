//
//  ChatMessageService.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-03-14.
//

import Appwrite
import Foundation
import JSONCodable

protocol ChatMessageServiceProtocol {
    func createMessage(message: ChatMessageModel) async throws
        -> ChatMessageDocument
    func getMessage(messageId: String) async throws -> ChatMessageDocument?
    func listMessagesForChat(chatId: String, queries: [String]?) async throws
        -> [ChatMessageDocument]
    func deleteMessage(messageId: String) async throws
}

class ChatMessageService: ChatMessageServiceProtocol {
    private let appwriteService: AppwriteService = AppwriteService.shared
    private let collectionId = "chatMessages"

    func createMessage(message: ChatMessageModel) async throws
        -> ChatMessageDocument
    {
        let document = try await appwriteService.databases.createDocument<
            ChatMessageModel
        >(
            databaseId: appwriteService.databaseId,
            collectionId: collectionId,
            documentId: ID.unique(),
            data: message.toJson(excludeId: true),
            permissions: nil,  // [Appwrite.Permission.write(Role.user(message.sentByUser.accountId))],
            nestedType: ChatMessageModel.self
        )
        return document
    }

    func getMessage(messageId: String) async throws -> ChatMessageDocument? {
        do {
            let document = try await appwriteService.databases.getDocument<
                ChatMessageModel
            >(
                databaseId: appwriteService.databaseId,
                collectionId: collectionId,
                documentId: messageId,
                queries: nil,
                nestedType: ChatMessageModel.self
            )
            return document
        } catch {
            throw NSError(domain: "Message not found", code: 404, userInfo: nil)
        }
    }

    func listMessagesForChat(chatId: String, queries: [String]? = nil)
        async throws -> [ChatMessageDocument]
    {
        let documents = try await appwriteService.databases.listDocuments<
            ChatMessageModel
        >(
            databaseId: appwriteService.databaseId,
            collectionId: collectionId,
            queries: ([Query.equal("chat", value: chatId)] + (queries ?? [])),
            nestedType: ChatMessageModel.self
        )
        return documents.documents
    }

    func deleteMessage(messageId: String) async throws {
        do {
            try await appwriteService.databases.deleteDocument(
                databaseId: appwriteService.databaseId,
                collectionId: collectionId,
                documentId: messageId
            )
        } catch {
            throw NSError(
                domain: "Failed to delete message", code: 500, userInfo: nil)
        }
    }
}
