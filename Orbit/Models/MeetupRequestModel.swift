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
    let intention: MeetupIntention
    let createdBy: UserModel
    let meetupApprovals: [MeetupApprovalModel]
    // enum type: coffee, meal, indoor activity, outdoor activity, event, other
    let type: MeetupType

    // Helper computed properties to get Date objects when needed
    var startTimeDate: Date? {
        ISO8601DateFormatter().date(from: startTime)
    }
    
    var endTimeDate: Date? {
        ISO8601DateFormatter().date(from: endTime)
    }

    static func mock() -> Self {
        let formatter = ISO8601DateFormatter()
        let startTime = Date().addingTimeInterval(7200)
        let endTime = startTime.addingTimeInterval(3600) // Add 1 hour
        return .init(
            title: "\"How do you plan to make the best of your university experience?\"",
            startTime: formatter.string(from: startTime),
            endTime: formatter.string(from: endTime),
            areaId: 521_659_157,
            description:
                "It's been hard for me to balance out grades and social life. Wondering how others do it",
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
