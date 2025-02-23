//
//  UserLinkModel.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-02-23.
//

import Appwrite
import Foundation

struct UserLinkModel: Codable, Equatable, Identifiable, CodableDictionaryConvertible {
    let platform: UserLinkPlatform
    let value: String

    static func mock() -> Self {
        return .init(platform: .instagram, value: "https://instagram.com/example")
    }

    var id: String { platform.rawValue + value }
}

enum UserLinkPlatform: String, Codable {
    case instagram
    case x
    case linkedIn
    case tikTok
    case bluesky
    case other
}

typealias UserLinkDocument = AppwriteModels.Document<UserLinkModel>

extension UserLinkDocument {
    static func mock() -> UserLinkDocument {
        return AppwriteModels.Document<UserLinkModel>.mock(
            data: UserLinkModel.mock()
        )
    }
}
