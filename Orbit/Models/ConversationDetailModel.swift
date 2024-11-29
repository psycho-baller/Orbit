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
    var lastSenderId: String  //need this to check whether new message should be displayed or not (sender should not get new message dot for their own message)
    
    mutating func update(with message: MessageDocument) {
        self.lastMessage = message.data.message
        self.timestamp = message.createdAt
        self.isRead = message.data.isRead ?? false
        self.lastSenderId = message.data.senderAccountId
    }
}
