//
//  UserReportModel.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-03-31.
//

import Appwrite
import Foundation

enum ReportStatus: String, Codable, CaseIterable {
    case pending
    case reviewed
    case resolved
}

struct UserReportModel: Codable, Identifiable, CodableDictionaryConvertible {
    let id: String
    let reporter: UserModel
    let reported: UserModel
    var reason: String
    var status: ReportStatus

    enum CodingKeys: String, CodingKey {
        case id = "$id"
        case reporter, reported, reason, status
    }

    init(
        id: String = UUID().uuidString,
        reporter: UserModel,
        reported: UserModel,
        reason: String,
        status: ReportStatus = .pending
    ) {
        self.id = id
        self.reporter = reporter
        self.reported = reported
        self.reason = reason
        self.status = status
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

    static func mock() -> UserReportModel {
        return UserReportModel(
            id: "report1",
            reporter: UserModel.mock(),
            reported: UserModel.mock2(),
            reason: "Inappropriate behavior",
            status: .pending
        )
    }
}

typealias UserReportDocument = AppwriteModels.Document<UserReportModel>

extension UserReportDocument {
    static func mock() -> UserReportDocument {
        return AppwriteModels.Document<UserReportModel>.mock(
            data: UserReportModel.mock()
        )
    }
}
