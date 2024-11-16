//
//  MessageModel.swift
//  Orbit
//
//  Created by Jessy Tseng on 2024-11-02.
//

import Foundation
import Appwrite
import AppwriteModels


struct MessageModel: Codable, Equatable{
    let conversationId: String
    let senderAccountId: String
    let message: String
    let createdAt: String
    let isRead: Bool
        
    
    init(conversationId: String, senderAccountId: String, message: String, createdAt: String, isRead: Bool=false) {
        self.conversationId = conversationId
        self.senderAccountId = senderAccountId
        self.message = message
        self.createdAt = createdAt
        self.isRead = isRead
    }
    
   
    
}

struct CustomMessageDocument: Identifiable, Decodable {
    let id: String
    let data: MessageModel
}

typealias MessageDocument = AppwriteModels.Document<MessageModel>





