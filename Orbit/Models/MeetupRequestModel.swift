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
    let startTime: String
    let endTime: String
    let areaId: Int
    let description: String
    // enum status: active, completed, cancelled
    let status: MeetupStatus
    // enum intention: friendship, dating
    let intention: Meetupintention
    let createdBy: UserModel
    let meetupApprovals: [MeetupApprovalModel]
    // enum type: coffee, meal, indoor activity, outdoor activity, event, other
    let type: MeetupType

    static func mock() -> Self {
        return .init(
            title: "Test",
            startTime: "2025-02-20T12:00:00Z",
            endTime: "2025-02-20T13:00:00Z",
            areaId: 1,
            description: "Test",
            status: .active,
            intention: .friendship,
            createdBy: .mockNoPendingMeetups(),
            meetupApprovals: [],
            type: .meal
        )
    }
    var id: String { startTime + createdBy.accountId }
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
enum Meetupintention: String, Codable {
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
