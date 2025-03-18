//
//  ChatMessageModel.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-03-14.
//

import Appwrite
import Foundation

struct ChatMessageModel: Codable, Identifiable, CodableDictionaryConvertible {
    let id: String
    let sentByUser: UserModel?
    let chat: ChatModel?
    let content: String
    let timestamp: String
    let createdAt: String
    var isRead: Bool?

    enum CodingKeys: String, CodingKey {
        case id = "$id"
        case sentByUser, chat, content, isRead, timestamp, createdAt
    }

    init(
        id: String = UUID().uuidString,
        sentByUser: UserModel? = nil,
        chat: ChatModel? = nil,
        content: String,
        timestamp: String = ISO8601DateFormatter().string(from: Date()),
        createdAt: String = DateFormatterUtility.formatISO8601(Date()),
        isRead: Bool? = false
    ) {
        self.id = id
        self.sentByUser = sentByUser
        self.chat = chat
        self.content = content
        self.isRead = isRead
        self.timestamp = timestamp
        self.createdAt = createdAt
    }
    
    var createdAtDate: Date? {
            return DateFormatterUtility.parseISO8601(timestamp)
        }
    
    static func mock() -> Self {
        return .init(
            id: "message-123",
            sentByUser: .mock(),
            content: "Hey, looking forward to meeting up!",
            timestamp: DateFormatterUtility.formatISO8601(Date()),
            createdAt: DateFormatterUtility.formatISO8601(Date()),  // Store as ISO8601
            isRead: false
        )
    }

    static func mockOtherUserSent() -> Self {
        return .init(
            id: "message-12",
            sentByUser: .mock2(),
            content: "Hey, looking forward to meeting up!",
            timestamp: DateFormatterUtility.formatISO8601(Date()),
            createdAt: DateFormatterUtility.formatISO8601(Date().addingTimeInterval(-300)),  // 5 mins ago
            isRead: true
        )
    }

    func toJson(excludeId: Bool = false) -> [String: Any] {
        var json =
            try! JSONSerialization.jsonObject(
                with: JSONEncoder().encode(self),
                options: []
            ) as! [String: Any]

        if excludeId {
            json.removeValue(forKey: "$id")  // 🚀 Removes `id` to avoid Appwrite error
        }

        json["sentByUser"] = self.sentByUser?.id
        json["chat"] = self.chat?.id

        return json
    }
}

typealias ChatMessageDocument = AppwriteModels.Document<ChatMessageModel>

extension ChatMessageDocument {
    static func mock() -> ChatMessageDocument {
        return AppwriteModels.Document<ChatMessageModel>.mock(
            data: ChatMessageModel.mock()
        )
    }
}
