//
//  ChatRequest.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-11-14.
//

import Appwrite
import Foundation

struct ChatRequestModel: Codable, Identifiable, CodableDictionaryConvertible {
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

    static func mock() -> ChatRequestModel {
        return .init(
            senderAccountId: "user123",
            receiverAccountId: "user456",
            message: "Hey! Want to grab coffee?",
            status: .pending
        )
    }
}

typealias ChatRequestDocument = AppwriteModels.Document<ChatRequestModel>

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

extension UserDocument {
    static func mock() -> ChatRequestDocument {
        return AppwriteModels.Document<ChatRequestModel>.mock(
            data: ChatRequestModel.mock()
        )
    }
}

// Mock data for testing
let distantPast = Date(timeIntervalSince1970: -1_000_000_000)
let dateFormatter = DateFormatter()
let distantPastString = dateFormatter.string(from: distantPast)

//struct IdentifiableDocument<T: Identifiable & Codable>: Identifiable {
//    let document: AppwriteModels.Document<T>
//
//    var id: T.ID {
//        return document.data.id
//    }
//}
