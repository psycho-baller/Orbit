//
//  MessageModel.swift
//  Orbit
//
//  Created by Jessy Tseng on 2024-11-02.
//

import Appwrite
import AppwriteModels
import Foundation

struct MessageModel: Codable, Equatable {
    let conversationId: String
    let senderAccountId: String
    let message: String
    let createdAt: String
    let isRead: Bool?

    init(conversationId: String, senderAccountId: String, message: String, isRead: Bool = nil) {
        self.conversationId = conversationId
        self.senderAccountId = senderAccountId
        self.message = message
        self.isRead = isRead
    }
}

typealias MessageDocument = AppwriteModels.Document<MessageModel>
