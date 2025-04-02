//
//  ChatService.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-03-14.
//

//
//  ChatService.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-02-20.
//

import Appwrite
import Foundation
import JSONCodable

protocol ChatServiceProtocol {
    func createChat(chat: ChatModel) async throws -> ChatDocument
    func getChat(chatId: String) async throws -> ChatDocument?
    func updateChat(chatId: String, updatedChat: ChatModel) async
        -> ChatDocument?
    func deleteChat(chatId: String) async throws
    func listChats(queries: [String]?) async throws -> [ChatDocument]
}

class ChatService: ChatServiceProtocol {
    private let appwriteService: AppwriteService = AppwriteService.shared
    private let collectionId = "chats"

    func createChat(chat: ChatModel) async throws -> ChatDocument {
        let document = try await appwriteService.databases.createDocument<
            ChatModel
        >(
            databaseId: appwriteService.databaseId,
            collectionId: collectionId,
            documentId: ID.unique(),
            data: chat.toJson(excludeId: true),
            permissions: nil,  // [Appwrite.Permission.write(Role.user(chat.createdByUser.accountId))],
            nestedType: ChatModel.self
        )
        return document
    }

    func getChat(chatId: String) async throws -> ChatDocument? {
        do {
            let document = try await appwriteService.databases.getDocument<
                ChatModel
            >(
                databaseId: appwriteService.databaseId,
                collectionId: collectionId,
                documentId: chatId,
                queries: nil,
                nestedType: ChatModel.self
            )
            return document
        } catch {
            throw NSError(domain: "Chat with chatID \(chatId) not found", code: 404, userInfo: nil)
        }
    }

    func updateChat(chatId: String, updatedChat: ChatModel) async
        -> ChatDocument?
    {
        do {
            let updatedDocument = try await appwriteService.databases
                .updateDocument<ChatModel>(
                    databaseId: appwriteService.databaseId,
                    collectionId: collectionId,
                    documentId: chatId,
                    data: updatedChat.toJson(),
                    permissions: nil,
                    nestedType: ChatModel.self
                )
            return updatedDocument
        } catch {
            print(
                "ChatService - updateChat: Error: \(error.localizedDescription)"
            )
            return nil
            //            throw error
        }
    }

    func deleteChat(chatId: String) async throws {
        do {
            try await appwriteService.databases.deleteDocument(
                databaseId: appwriteService.databaseId,
                collectionId: collectionId,
                documentId: chatId
            )
        } catch {
            throw NSError(
                domain: "Failed to delete chat", code: 500, userInfo: nil)
        }
    }

    func listChats(queries: [String]? = nil) async throws -> [ChatDocument] {
        let documents = try await appwriteService.databases.listDocuments<
            ChatModel
        >(
            databaseId: appwriteService.databaseId,
            collectionId: collectionId,
            queries: queries,
            nestedType: ChatModel.self
        )
        return documents.documents
    }
}
