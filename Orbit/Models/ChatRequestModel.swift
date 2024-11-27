//
//  ChatRequest.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-11-14.
//

import Appwrite
import Foundation

struct ChatRequestModel: Codable, Identifiable {
    var id: String {
        return "\(senderAccountId)_\(receiverAccountId)_\(message)"
    }
    var senderAccountId: String  // ID of the user sending the request
    var receiverAccountId: String  // ID of the user receiving the request
    var message: String  // Message content sent by the sender
    var status: RequestStatus?  // Status of the chat request

    enum RequestStatus: String, Codable {
        case pending
        case approved
        case declined
    }
}

typealias ChatRequestDocument = AppwriteModels.Document<ChatRequestModel>

<<<<<<< HEAD
=======
// Custom mock for AppwriteModels.Document
struct MockDocument<T: Codable>: Identifiable {
    var id: String
    var collectionId: String
    var databaseId: String
    var createdAt: String
    var updatedAt: String
    var permissions: [String]
    var data: T
}

// Mock data for testing
let distantPast = Date(timeIntervalSince1970: -1_000_000_000)
let dateFormatter = DateFormatter()
let distantPastString = dateFormatter.string(from: distantPast)

let mockChatRequest = ChatRequestModel(
    senderAccountId: "user123",
    receiverAccountId: "user456",
    message: "Hey! Want to grab coffee?",
    status: .pending
)

// Create a mock ChatRequestDocument
let mockChatRequestDocument = MockDocument<ChatRequestModel>(
    id: mockChatRequest.id,
    collectionId: "chat-requests",
    databaseId: "chat-requests",
    createdAt: distantPastString,
    updatedAt: distantPastString,
    permissions: [],
    data: mockChatRequest
)

>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
//struct IdentifiableDocument<T: Identifiable & Codable>: Identifiable {
//    let document: AppwriteModels.Document<T>
//
//    var id: T.ID {
//        return document.data.id
//    }
//}
