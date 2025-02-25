//
//  MeetupApprovalModel.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-02-20.
//

import Appwrite
import CoreLocation
import Foundation
import UIKit

struct MeetupRequestModel: Codable, Equatable, Identifiable,
    CodableDictionaryConvertible
{
    let title: String
    let startTime: Date
    let endTime: Date
    let areaId: Int
    let description: String
    // enum status: active, completed, cancelled
    let status: MeetupStatus
    // enum intention: friendship, dating
    let intention: MeetupIntention
    let createdBy: UserModel
    let meetupApprovals: [MeetupApprovalModel]
    // enum type: coffee, meal, indoor activity, outdoor activity, event, other
    let type: MeetupType

    static func mock() -> Self {
        return .init(
            title: "Test",
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            areaId: 1,
            description: "Test description",
            status: .active,
            intention: .friendship,
            createdBy: .mockNoPendingMeetups(),
            meetupApprovals: [],
            type: .meal
        )
    }
    var id: String { startTime.ISO8601Format() + createdBy.accountId }
    //    var id: String {
    //        return
    //    }

    //    init(
    //    ) {
    //        self.
    //    }
}

enum MeetupStatus: String, Codable {
    case active
    case completed
    case cancelled
}
enum MeetupIntention: String, Codable {
    case friendship
    case dating
}
enum MeetupType: String, Codable {
    case coffee
    case meal
    case indoorActivity
    case outdoorActivity
    case event
    case other
}

typealias MeetupRequestDocument = AppwriteModels.Document<MeetupRequestModel>

extension MeetupRequestDocument {
    static func mock() -> MeetupRequestDocument {
        return AppwriteModels.Document<MeetupRequestModel>.mock(
            data: MeetupRequestModel.mock()
        )
    }
}
