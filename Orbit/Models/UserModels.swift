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
    var currentAreaId: String?  // References Area collection
    var profilePictureUrl: String?

    // Onboarding-related fields
    var personalPreferences: PersonalPreferences?  // To store answers to Profile Questions
    var socialStyle: SocialStyleModel?  // To store answers to Social Style
    var interactionPreferences: InteractionPreferencesModel?  // To store Interaction Preferences
    var friendshipValues: FriendshipValuesModel?  // To store Friendship Values
    var socialSituations: SocialSituationsModel?  // To store Social Situations
    var hasCompletedOnboarding: Bool? = false  // Indicates if onboarding is completed
    //    var userLocations: String?

    static func == (lhs: UserModel, rhs: UserModel) -> Bool {
        return lhs.accountId == rhs.accountId
    }

    init(
        accountId: String,
        name: String,
        interests: [String]? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        isInterestedToMeet: Bool? = nil,
        conversations: [String]? = nil,
        currentAreaId: String? = nil,
        profilePictureUrl: String? = nil,
        personalPreferences: PersonalPreferences? = nil,
        socialStyle: SocialStyleModel? = nil,
        interactionPreferences: InteractionPreferencesModel? = nil,
        friendshipValues: FriendshipValuesModel? = nil,
        socialSituations: SocialSituationsModel? = nil,
        hasCompletedOnboarding: Bool? = false
            //        userLocations: String? = nil
    ) {
        self.accountId = accountId
        self.name = name
        self.interests = interests
        self.latitude = latitude
        self.longitude = longitude
        self.isInterestedToMeet = isInterestedToMeet
        self.conversations = conversations
        self.currentAreaId = currentAreaId
        self.profilePictureUrl = profilePictureUrl
        self.personalPreferences = personalPreferences
        self.socialStyle = socialStyle
        self.interactionPreferences = interactionPreferences
        self.friendshipValues = friendshipValues
        self.socialSituations = socialSituations
        self.hasCompletedOnboarding = hasCompletedOnboarding
        //        self.userLocations = userLocations
    }

    func update(
        name: String? = nil,
        interests: [String]? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        isInterestedToMeet: Bool? = nil,
        conversations: [String]? = nil,
        personalPreferences: PersonalPreferences? = nil,
        socialStyle: SocialStyleModel? = nil,
        interactionPreferences: InteractionPreferencesModel? = nil,
        friendshipValues: FriendshipValuesModel? = nil,
        socialSituations: SocialSituationsModel? = nil
            //        userLocations: String? = nil
    ) -> UserModel {
        return UserModel(
            accountId: self.accountId,  // accountId stays the same
            name: name ?? self.name,
            interests: interests ?? self.interests,
            latitude: latitude ?? self.latitude,
            longitude: longitude ?? self.longitude,
            isInterestedToMeet: isInterestedToMeet ?? self.isInterestedToMeet,
            conversations: conversations ?? self.conversations,
            currentAreaId: self.currentAreaId,  // currentAreaId remains unchanged
            profilePictureUrl: self.profilePictureUrl,  // profilePictureUrl remains unchanged
            personalPreferences: personalPreferences
                ?? self.personalPreferences,
            socialStyle: socialStyle ?? self.socialStyle,
            interactionPreferences: interactionPreferences
                ?? self.interactionPreferences,
            friendshipValues: friendshipValues ?? self.friendshipValues,
            socialSituations: socialSituations ?? self.socialSituations
                //            userLocations: userLocations ?? self.userLocations
        )
    }
}

var profileImageURL: URL?
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

struct TimeRangeConfig: Codable {
    var dayOfWeek: Int  // 0 is monday, 1 is tuesday, and so on
    var startTime: Date
    var endTime: Date
}

typealias UserDocument = AppwriteModels.Document<UserModel>
