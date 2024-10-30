//
//  MessagingService.swift
//  Orbit
//
//  Created by Jessy Tseng on 2024-10-29.
//

import Foundation
import Appwrite

protocol MessagingServiceProtocol {
    func getMessages(accountId: String) async throws -> [Any]
    
}

class MessagingService: MessagingServiceProtocol {
    private let appwriteService: AppwriteService = AppwriteService.shared
    private let collectionId = "messages"
    
    func getMessages(accountId: String, numOfMessages: Int = 100) async throws -> [Any] {
        
        let queries = [
            Query.equal("acountId", value: accountId),
            Query.orderAsc("createdAt"),
            Query.limit(numOfMessages)
        ]
        let messages = try await appwriteService.read(collectionId: self.collectionId, queries: queries)
        return messages

    }
}
