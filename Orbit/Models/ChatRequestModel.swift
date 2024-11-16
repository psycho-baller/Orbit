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
        return "\(senderAccountId)_\(receiverAccountId)"
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


//struct IdentifiableDocument<T: Identifiable & Codable>: Identifiable {
//    let document: AppwriteModels.Document<T>
//    
//    var id: T.ID {
//        return document.data.id
//    }
//}
