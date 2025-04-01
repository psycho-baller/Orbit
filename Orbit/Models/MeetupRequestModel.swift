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
    var status: MeetupStatus
    // enum intention: friendship, relationship
    let intention: MeetupIntention
    //    let createdByUserId: String
    let createdByUser: UserModel?
    //    let meetupApprovalIds: [String]
    //    let meetupApprovals: [MeetupApprovalModel]?
    let chats: [ChatModel]?
    // enum type: coffee, meal, indoor activity, outdoor activity, event, other
    let type: MeetupType
    var genderPreference: GenderPreference

    enum CodingKeys: String, CodingKey {
        case id = "$id"  // Maps Appwrite's `$id` to `id`
        case title, startTime, endTime, areaId, description, status
        case intention, createdByUser, chats, type, genderPreference
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
        //        meetupApprovals: [MeetupApprovalModel] = [],
        chats: [ChatModel] = [],
        type: MeetupType,
        genderPreference: GenderPreference
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
        self.chats = chats
        self.type = type
        self.genderPreference = genderPreference
    }

    //    init(from decoder: Decoder) throws {
    //        let container = try decoder.container(keyedBy: CodingKeys.self)
    //        id = try container.decode(String.self, forKey: .id)
    //        title = try container.decode(String.self, forKey: .title)
    //        startTime = try container.decode(String.self, forKey: .startTime)
    //        endTime = try container.decode(String.self, forKey: .endTime)
    //        areaId = try container.decode(Int.self, forKey: .areaId)
    //        description = try container.decode(String.self, forKey: .description)
    //        status = try container.decode(MeetupStatus.self, forKey: .status)
    //        intention = try container.decode(MeetupIntention.self, forKey: .intention)
    //        createdByUser = try container.decodeIfPresent(UserModel.self, forKey: .createdByUser)
    //        chats = try container.decodeIfPresent([ChatModel].self, forKey: .chats) ?? []
    //        type = try container.decode(MeetupType.self, forKey: .type)
    //    }

    // Helper computed properties to get Date objects when needed
    var startTimeDate: Date? {
        return DateFormatterUtility.parseISO8601(startTime)
    }

    var endTimeDate: Date? {
        return DateFormatterUtility.parseISO8601(endTime)
    }

    static func mock() -> Self {
        let startTime = Date().addingTimeInterval(7200)
        let endTime = startTime.addingTimeInterval(3600)  // Add 1 hour
        return .init(
            id: "67ce15c07501e11e1fa3",
            title:
                "\"How do you plan to make the best of your university experience?\"",
            startTime: DateFormatterUtility.formatISO8601(startTime),
            endTime: DateFormatterUtility.formatISO8601(endTime),
            areaId: 521_659_157,
            description:
                "It's been hard for me to balance out grades and social life. Wondering how others do it",
            status: .active,
            intention: .friendship,
            createdByUser: .mock2(),
            chats: [],
            type: .meal,
            genderPreference: .any
        )
    }

    static func mock2() -> Self {
        let startTime = Date().addingTimeInterval(10_800)  // +3 hours
        let endTime = startTime.addingTimeInterval(5400)  // +1.5 hours
        return .init(
            id: "abc1234567890",
            title: "What's your biggest goal this semester?",
            startTime: DateFormatterUtility.formatISO8601(startTime),
            endTime: DateFormatterUtility.formatISO8601(endTime),
            areaId: 521_659_158,
            description:
                "Trying to stay focused and build better study habits—curious what works for others.",
            status: .active,
            intention: .friendship,
            createdByUser: .mock(),
            chats: [
                .mock()
            ],
            type: .coffee,
            genderPreference: .any
        )
    }

    static func mock3() -> Self {
        let startTime = Date().addingTimeInterval(14_400)  // +4 hours
        let endTime = startTime.addingTimeInterval(3600)  // +1 hour
        return .init(
            id: "xyz9876543210",
            title: "Anyone else looking to meet someone new this weekend?",
            startTime: DateFormatterUtility.formatISO8601(startTime),
            endTime: DateFormatterUtility.formatISO8601(endTime),
            areaId: 521_659_159,
            description:
                "Hoping to meet someone who’s also into outdoor activities or trying new things around campus.",
            status: .filled,
            intention: .relationship,
            createdByUser: .mock2(),
            chats: [],
            type: .outdoorActivity,
            genderPreference: .women
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
        json["chats"] = self.chats?.map(\.id)

        print("data: \(json)")

        return json
    }

    //    func hasChatWith(userId: String) -> Bool {
    //        return createdByUser?.id != userId
    //            && createdChats.contains { $0.createdByUser.id == userId }
    //    }
}

enum MeetupStatus: String, Codable {
    case active
    case completed
    case cancelled
    case filled

}

enum MeetupIntention: String, Codable {
    case friendship
    case relationship

    var icon: String {
        switch self {
        case .friendship: return "figure.2"
        case .relationship: return "heart.fill"
        }
    }
}

enum GenderPreference: String, CaseIterable, Identifiable, Codable {
    case any = "Any"
    case women = "Women"
    case men = "Men"
    case nonBinary = "Non-binary"

    var id: String { self.rawValue }
    var icon: String {
        "figure.stand.dress.line.vertical.figure"
    }
}

enum MeetupType: String, Codable {
    case coffee
    case meal
    case indoorActivity
    case outdoorActivity
    case event
    case other

    var icon: String {
        switch self {
        case .coffee: return "cup.and.saucer.fill"
        case .meal: return "fork.knife"
        case .indoorActivity: return "house.fill"
        case .outdoorActivity: return "figure.hiking"
        case .event: return "calendar"
        case .other: return "ellipsis.circle.fill"
        }
    }
}

typealias MeetupRequestDocument = AppwriteModels.Document<MeetupRequestModel>

extension MeetupRequestDocument {
    static func mock() -> MeetupRequestDocument {
        return AppwriteModels.Document<MeetupRequestModel>.mock(
            data: MeetupRequestModel.mock()
        )
    }
}
