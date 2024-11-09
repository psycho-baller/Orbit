//
//  ConversationModel.swift
//  Orbit
//
//  Created by Jessy Tseng on 2024-11-02.
//


import Foundation
import Appwrite

struct ConversationModel: Codable {
    let participants: [String]?
    
    init(participants: [String]) {
        self.participants = participants
    }
}

typealias ConversationDocument = AppwriteModels.Document<ConversationModel>