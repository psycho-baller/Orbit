//
//  UserLanguageModel.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-02-23.
//

import Appwrite
import Foundation

struct UserLanguageModel: Codable, Equatable, Identifiable,
    CodableDictionaryConvertible
{
    let languageId: String
    let proficiency: Int  // 0-5 scale

    static func mock() -> Self {
        return .init(languageId: "ara", proficiency: 4)
    }

    var id: String { languageId }
}

/// The model you want to decode from JSON
struct Language: Codable, Identifiable {
    let languageId: String
    let name: String
    let autonym: String

    var id: String { languageId }
}

typealias UserLanguageDocument = AppwriteModels.Document<UserLanguageModel>

extension UserLanguageDocument {
    static func mock() -> UserLanguageDocument {
        return AppwriteModels.Document<UserLanguageModel>.mock(
            data: UserLanguageModel.mock()
        )
    }
}
