//
//  MessageModel.swift
//  Orbit
//
//  Created by Jessy Tseng on 2024-11-02.
//

import Foundation
import Appwrite

struct MessageModel: Identifiable, Codable {
    let id: String
    let conversationId: String
    let senderAccountId: String
    let message: String
    let createdAt: Date
    let isRead: Bool
        
    
    init(id: String, conversationId: String, senderAccountId: String, message: String, createdAt: Date, isRead: Bool=false) {
        self.id = id
        self.conversationId = conversationId
        self.senderAccountId = senderAccountId
        self.message = message
        self.createdAt = createdAt
        self.isRead = isRead
    }
}

// MARK: - Convenience Methods
extension MessageModel {
//    var isFromCurrentUser: Bool {
//        // Assuming you have a way to get the current user's ID
//        senderId == CurrentUser.shared.id
//    }
    
    func formattedTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: createdAt)
    }
}

typealias MessageDocument = AppwriteModels.Document<MessageModel>
