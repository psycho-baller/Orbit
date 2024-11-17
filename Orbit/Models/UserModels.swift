//
//  UserModels.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-10-05.
//  Copyright © 2024 CPSC 575. All rights reserved.
//

import Appwrite
import CoreLocation
import Foundation
import UIKit

struct UserModel: Codable, Identifiable, Equatable {
    let accountId: String
    var id: String {
        return accountId
    }
    var name: String
    var interests: [String]?
    var latitude: Double?
    var longitude: Double?
    var isInterestedToMeet: Bool?
    var conversations: [String]?

    static func == (lhs: UserModel, rhs: UserModel) -> Bool {
        return lhs.accountId == rhs.accountId
    }

    init(
        accountId: String, name: String, interests: [String]? = nil,
        latitude: Double? = nil, longitude: Double? = nil,
        isInterestedToMeet: Bool? = nil, conversations: [String]? = nil
    ) {
        self.accountId = accountId
        self.name = name
        self.interests = interests
        self.latitude = latitude
        self.longitude = longitude
        self.isInterestedToMeet = isInterestedToMeet
        self.conversations = conversations

    }
    func update(
        name: String? = nil,
        interests: [String]? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        isInterestedToMeet: Bool? = nil,
        conversations: [String]? = nil
    ) -> UserModel {
        return UserModel(
            accountId: self.accountId,  // accountId stays the same
            name: name ?? self.name,
            interests: interests ?? self.interests,
            latitude: latitude ?? self.latitude,
            longitude: longitude ?? self.longitude,
            isInterestedToMeet: isInterestedToMeet ?? self.isInterestedToMeet,
            conversations: conversations ?? self.conversations
        )
    }

    var profileImageURL: URL?
    var currentAreaId: String?  // References Area collection
    var inactiveAreas: [Int] = []  // Array of area_id references
    //    var inactiveTimes: [TimeRangeConfig] = []

    //    init(accountId: String, name: String, interests: [String]? = nil, latitude: Double? = nil, longitude: Double? = nil, isInterestedToMeet: Bool? = nil) {
    //            self.accountId = accountId
    //            self.name = name
    //            self.interests = interests
    //            self.latitude = latitude
    //            self.longitude = longitude
    //            self.isInterestedToMeet = isInterestedToMeet
    //        }
    //
    //    var isOnline: Bool
    //    var lastActive: Date
    //    var lastActive:
    //    let bio: String?
    //    let friends: [String]?
    //    let profilePictureId: String?  // Reference to the File ID
    //    let settings: Settings?
}

struct TimeRangeConfig: Codable {
    var dayOfWeek: Int  // 0 is monday, 1 is tuesday, and so on
    var startTime: Date
    var endTime: Date
}

typealias UserDocument = AppwriteModels.Document<UserModel>
