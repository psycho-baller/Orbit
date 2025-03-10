//
//  UserModel.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-02-20.
//

import Appwrite
import CoreLocation
import Foundation
import UIKit

struct MeetupApprovalModel: Codable, Equatable, CodableDictionaryConvertible {
    let id: String
    //    let approvedByUserId: String
    let approvedByUser: UserModel?
    //    let meetupRequestId: String
    let meetupRequest: MeetupRequestModel?
    let firstMessage: String?

    enum CodingKeys: String, CodingKey {
        case id = "$id"  // Maps Appwrite's `$id` to `id`
        case approvedByUser, meetupRequest, firstMessage
    }

    init(
        id: String = UUID().uuidString,  // Generates a random ID if not provided
        approvedByUser: UserModel?,
        meetupRequest: MeetupRequestModel?,
        firstMessage: String? = ""
    ) {
        self.id = id
        self.approvedByUser = approvedByUser
        self.meetupRequest = meetupRequest
        self.firstMessage = firstMessage
    }
    static func mock() -> Self {
        return .init(
            id: "123",
            //            approvedByUserId: "",
            approvedByUser: .mock(),
            //            meetupRequestId: "",
            meetupRequest: .mock(),
            firstMessage: "Looking forward to this!"
        )
    }
    // var id: String {
    //     return "approvedB + meetupReques"
    // }
    //    init(
    //    ) {
    //        self.
    //    }

    //    func update(
    //        name: String? = nil,
    //    ) -> MeetupApprovalModel {
    //        return MeetupApprovalModel(

    //        )
    //    }
    func toJson(excludeId: Bool = false) -> [String: Any] {
        var json =
            try! JSONSerialization.jsonObject(
                with: JSONEncoder().encode(self),
                options: []
            ) as! [String: Any]

        if excludeId {
            json.removeValue(forKey: "$id")  // 🚀 Removes `id` to avoid Appwrite error
        }
        // Convert approvedByUser from UserModel to String (user ID)
        json["approvedByUser"] = self.approvedByUser?.id

        // Convert meetupRequest from MeetupRequestModel to String (request ID)
        json["meetupRequest"] = self.meetupRequest?.id

        return json
    }
}

typealias MeetupApprovalDocument = AppwriteModels.Document<MeetupApprovalModel>

extension MeetupApprovalDocument {
    static func mock() -> MeetupApprovalDocument {
        return AppwriteModels.Document<MeetupApprovalModel>.mock(
            data: MeetupApprovalModel.mock()
        )
    }
}
