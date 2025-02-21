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
    let approvedBy: UserModel
    let meetupRequest: MeetupRequestModel
    let firstMessage: String

    static func mock() -> Self {
        return .init(
            approvedBy: UserModel.mock(),
            meetupRequest: MeetupRequestModel.mock(),
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
}

typealias MeetupApprovalDocument = AppwriteModels.Document<MeetupApprovalModel>

extension MeetupApprovalDocument {
    static func mock() -> MeetupApprovalDocument {
        return AppwriteModels.Document<MeetupApprovalModel>.mock(
            data: MeetupApprovalModel.mock()
        )
    }
}
