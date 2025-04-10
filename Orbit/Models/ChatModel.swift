//
//  ChatModel.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-03-14.
//

import Appwrite
import Foundation

struct ChatModel: Codable, Equatable, Hashable, Identifiable,
    CodableDictionaryConvertible
{
    let id: String
    let createdByUser: UserModel?
    let otherUser: UserModel?
    let meetupRequest: MeetupRequestModel?
    let messages: [ChatMessageModel]?
    var meetupConfirmed: Bool

    enum CodingKeys: String, CodingKey {
        case id = "$id"  // Maps Appwrite's `$id` to `id`
        case createdByUser, otherUser, meetupRequest, messages, meetupConfirmed
    }

    static func == (lhs: ChatModel, rhs: ChatModel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    init(
        id: String = UUID().uuidString,
        createdByUser: UserModel? = nil,
        otherUser: UserModel? = nil,
        meetupRequest: MeetupRequestModel? = nil,
        messages: [ChatMessageModel]? = [],
        meetupConfirmed: Bool = false
    ) {
        self.id = id
        self.createdByUser = createdByUser
        self.otherUser = otherUser
        self.meetupRequest = meetupRequest
        self.messages = messages
        self.meetupConfirmed = meetupConfirmed
    }

    static func mock() -> Self {
        return .init(
            id: UUID().uuidString,
            createdByUser: .mock2(),
            otherUser: .mock(),
//            meetupRequest: .mock(),
            messages: [
                .mock(), .mockOtherUserSent(), .mock2(), .mockOtherUserSent(),
            ]
        )
    }
    
    static func mock2() -> Self {
        return .init(
            id: UUID().uuidString,
            otherUser: .mock(),
//            meetupRequest: .mock(),
            messages: [
                .mockOtherUserSent(), .mock(), .mockOtherUserSent(), .mock2(),
            ]
        )
    }

    // Converts ChatModel to JSON (Removes `$id` when sending data to Appwrite)
    func toJson(excludeId: Bool = false) -> [String: Any] {
        var json =
            try! JSONSerialization.jsonObject(
                with: JSONEncoder().encode(self),
                options: []
            ) as! [String: Any]

        if excludeId {
            json.removeValue(forKey: "$id")  // 🚀 Removes `id` to avoid Appwrite error
        }

        // Convert Users and MeetupRequest to their respective IDs
        json["createdByUser"] = self.createdByUser?.id
        json["otherUser"] = self.otherUser?.id
        json["meetupRequest"] = self.meetupRequest?.id

        return json
    }
}

typealias ChatDocument = AppwriteModels.Document<ChatModel>

extension ChatDocument {
    static func mock() -> ChatDocument {
        return AppwriteModels.Document<ChatModel>.mock(
            data: ChatModel.mock()
        )
    }
}
