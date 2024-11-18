//
//  ConversationDetailModel.swift
//  Orbit
//
//  Created by Devon Tran on 2024-11-14.
//

import Foundation

struct ConversationDetailModel: Identifiable {
    let id: String
    let messagerName: String
    var lastMessage: String
    var timestamp: String
    var isRead: Bool
    
    mutating func update(with message: MessageDocument) {
        self.lastMessage = message.data.message
        self.timestamp = message.createdAt
        self.isRead = message.data.isRead ?? false
    }
}
