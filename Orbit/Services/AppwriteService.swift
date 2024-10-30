//
//  AppwriteService.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-10-05.
//  Copyright © 2024 CPSC 575. All rights reserved.
//

import Foundation
import Appwrite
import AppwriteModels

protocol AppwriteServiceProtocol {
    var client: Client { get }
    var account: Account { get }
    var databases: Databases { get }
    var storage: Storage { get }
}

class AppwriteService: AppwriteServiceProtocol {
    let client: Client
    let account: Account
    let databases: Databases
    let storage: Storage
    let realtime: Realtime

    let databaseId = "orbit"
    let collectionId = "users"
    let bucketId = "userAssets"
    //    var functionId = "YOUR_FUNCTION_ID"
    //    var executionId = ""
    //    var userId = ""
    //    var userEmail = ""
    //    var documentId = ""
    //    var fileId = ""

    static let shared = AppwriteService()
    
    
    init() {

        self.client = Client()
            .setEndpoint("https://cloud.appwrite.io/v1")
            .setProject("67017126001e334dd053")
            .setSelfSigned(true)  // For self signed certificates, only use for development

        self.account = Account(client)
        self.databases = Databases(client)
        self.storage = Storage(client)
        self.realtime = Realtime(client)

    }
    
    func create(
        collectionId: String,
        data: [String: String],
        permissions: [String]? = nil
    ) async throws -> Any {
        let document = try await databases.createDocument(
            databaseId: self.databaseId,
            collectionId: collectionId,
            documentId: ID.unique(),
            data: data,
            permissions: permissions
        )
        return document;
    }

    func read(collectionId: String, queries: [String]) async throws -> [Any] {
        let documents = try await databases.listDocuments(
            databaseId: self.databaseId,
            collectionId: collectionId,
            queries: queries
        )
        return documents
    }
    
    func update(
        collectionId: String,
        documentId: String,
        data: [String: String]? = nil,
        permissions: [String]? = nil
    ) async throws -> Any {
        let result = try await databases.updateDocument(
            databaseId: self.databaseId,
            collectionId: collectionId,
            documentId: documentId,
            data: data,
            permissions: permissions
        )
        return result;
    }
    
    func delete(collectionId: String, documentId: String) async throws -> Any {
        let result = try await databases.deleteDocument(
            databaseId: self.databaseId,
            collectionId: collectionId,
            documentId: documentId
        )
        return result
    }
}
