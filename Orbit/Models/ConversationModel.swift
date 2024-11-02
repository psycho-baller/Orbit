//
//  ConversationModel.swift
//  Orbit
//
//  Created by Jessy Tseng on 2024-11-02.
//


import Foundation
import Appwrite

struct ConversationModel: Identifiable, Codable {
    let id: String
    let participants: [String]
    
    init(id: String, participants: [String]) {
        self.id = id
        self.participants = participants
    }
}

typealias ConversationDocument = AppwriteModels.Document<ConversationModel>
