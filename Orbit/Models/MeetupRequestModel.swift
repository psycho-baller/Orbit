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
    let id: String
    let title: String
    let startTime: String
    let endTime: String
    let areaId: Int
    let description: String
    // enum status: active, completed, cancelled
    let status: MeetupStatus
    // enum intention: friendship, relationship
    let intention: MeetupIntention
    //    let createdByUserId: String
    let createdByUser: UserModel?
    //    let meetupApprovalIds: [String]
    let meetupApprovals: [MeetupApprovalModel]?
    // enum type: coffee, meal, indoor activity, outdoor activity, event, other
    let type: MeetupType

    enum CodingKeys: String, CodingKey {
        case id = "$id"  // Maps Appwrite's `$id` to `id`
        case title, startTime, endTime, areaId, description, status
        case intention, createdByUser, meetupApprovals, type
    }

    init(
        id: String = UUID().uuidString,  // Generates a random ID if not provided
        title: String,
        startTime: String,
        endTime: String,
        areaId: Int,
        description: String,
        status: MeetupStatus,
        intention: MeetupIntention,
        createdByUser: UserModel? = nil,
        meetupApprovals: [MeetupApprovalModel]? = [],
        type: MeetupType
    ) {
        self.id = id
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
        self.areaId = areaId
        self.description = description
        self.status = status
        self.intention = intention
        self.createdByUser = createdByUser
        self.meetupApprovals = meetupApprovals
        self.type = type
    }

    // Helper computed properties to get Date objects when needed
    var startTimeDate: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime, .withFractionalSeconds,
        ]
        print(startTime)
        print(formatter.date(from: startTime))
        return formatter.date(from: startTime)
    }

    var endTimeDate: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime, .withFractionalSeconds,
        ]
        print(endTime)
        print(formatter.date(from: endTime))
        return formatter.date(from: endTime)
    }

    static func mock() -> Self {
        let formatter = ISO8601DateFormatter()
        let startTime = Date().addingTimeInterval(7200)
        let endTime = startTime.addingTimeInterval(3600)  // Add 1 hour
        return .init(
            id: "67ce15c07501e11e1fa3",
            title:
                "\"How do you plan to make the best of your university experience?\"",
            startTime: formatter.string(from: startTime),
            endTime: formatter.string(from: endTime),
            areaId: 521_659_157,
            description:
                "It's been hard for me to balance out grades and social life. Wondering how others do it",
            status: .active,
            intention: .friendship,
            createdByUser: .mockNoPendingMeetups(),
            meetupApprovals: [],
            type: .meal
        )
    }

    func toJson(excludeId: Bool = false) -> [String: Any] {
        var json =
            try! JSONSerialization.jsonObject(
                with: JSONEncoder().encode(self),
                options: []
            ) as! [String: Any]

        if excludeId {
            // Removes `id` to avoid Appwrite error when creating a document
            json.removeValue(forKey: "$id")
        }

        json["createdByUser"] = self.createdByUser?.id
        json["meetupApprovals"] = self.meetupApprovals?.map { $0.id }

        print("data: \(json)")

        return json
    }
}

enum MeetupStatus: String, Codable {
    case active
    case completed
    case cancelled
}

enum MeetupIntention: String, Codable {
    case friendship
    case relationship
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
