//
//  UserBlockModel.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-03-31.
//

import Appwrite
import Foundation

struct UserBlockModel: Codable, Identifiable, CodableDictionaryConvertible {
    let id: String
    let blocker: UserModel
    let blocked: UserModel

    enum CodingKeys: String, CodingKey {
        case id = "$id"
        case blocker, blocked
    }

    init(
        id: String = UUID().uuidString,
        blocker: UserModel,
        blocked: UserModel
    ) {
        self.id = id
        self.blocker = blocker
        self.blocked = blocked
    }

    func toJson(excludeId: Bool = false) -> [String: Any] {
        var json =
            try! JSONSerialization.jsonObject(
                with: JSONEncoder().encode(self),
                options: []
            ) as! [String: Any]

        if excludeId {
            json.removeValue(forKey: "$id")
        }

        return json
    }

    static func mock() -> UserBlockModel {
        return UserBlockModel(
            id: "block1",
            blocker: UserModel.mock(),
            blocked: UserModel.mock2()
        )
    }
}

typealias UserBlockDocument = AppwriteModels.Document<UserBlockModel>

extension UserBlockDocument {
    static func mock() -> UserBlockDocument {
        return AppwriteModels.Document<UserBlockModel>.mock(
            data: UserBlockModel.mock()
        )
    }
}
