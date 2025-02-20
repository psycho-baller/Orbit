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
    var conversations: [String]?
    var currentAreaId: String?  // References Area collection
    var profilePictureUrl: String?
    var bio: String?  // User biography
    var dob: String?  // Date of birth

    // Onboarding-related fields
    var personalPreferences: PersonalPreferences?  // To store answers to Profile Questions
    var socialStyle: SocialStyleModel?  // To store answers to Social Style
    var interactionPreferences: InteractionPreferencesModel?  // To store Interaction Preferences
    var friendshipValues: FriendshipValuesModel?  // To store Friendship Values
    var socialSituations: SocialSituationsModel?  // To store Social Situations
    var hasCompletedOnboarding: Bool? = false  // Indicates if onboarding is completed

    static func == (lhs: UserModel, rhs: UserModel) -> Bool {
        return lhs.accountId == rhs.accountId
    }

    init(
        accountId: String,
        name: String,
        interests: [String]? = nil,
        conversations: [String]? = nil,
        currentAreaId: String? = nil,
        profilePictureUrl: String? = nil,
        bio: String? = nil,
        dob: String? = nil,
        personalPreferences: PersonalPreferences? = nil,
        socialStyle: SocialStyleModel? = nil,
        interactionPreferences: InteractionPreferencesModel? = nil,
        friendshipValues: FriendshipValuesModel? = nil,
        socialSituations: SocialSituationsModel? = nil,
        hasCompletedOnboarding: Bool? = false
    ) {
        self.accountId = accountId
        self.name = name
        self.interests = interests
        self.conversations = conversations
        self.currentAreaId = currentAreaId
        self.profilePictureUrl = profilePictureUrl
        self.bio = bio
        self.dob = dob
        self.personalPreferences = personalPreferences
        self.socialStyle = socialStyle
        self.interactionPreferences = interactionPreferences
        self.friendshipValues = friendshipValues
        self.socialSituations = socialSituations
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }

    func update(
        name: String? = nil,
        interests: [String]? = nil,
        conversations: [String]? = nil,
        bio: String? = nil,
        dob: String? = nil,
        personalPreferences: PersonalPreferences? = nil,
        socialStyle: SocialStyleModel? = nil,
        interactionPreferences: InteractionPreferencesModel? = nil,
        friendshipValues: FriendshipValuesModel? = nil,
        socialSituations: SocialSituationsModel? = nil
    ) -> UserModel {
        return UserModel(
            accountId: self.accountId,  // accountId stays the same
            name: name ?? self.name,
            interests: interests ?? self.interests,
            conversations: conversations ?? self.conversations,
            currentAreaId: self.currentAreaId,  // currentAreaId remains unchanged
            profilePictureUrl: self.profilePictureUrl,  // profilePictureUrl remains unchanged
            bio: bio ?? self.bio,
            dob: dob ?? self.dob,
            personalPreferences: personalPreferences
                ?? self.personalPreferences,
            socialStyle: socialStyle ?? self.socialStyle,
            interactionPreferences: interactionPreferences
                ?? self.interactionPreferences,
            friendshipValues: friendshipValues ?? self.friendshipValues,
            socialSituations: socialSituations ?? self.socialSituations
        )
    }
}

var profileImageURL: URL?
var inactiveAreas: [Int] = []  // Array of area_id references

struct TimeRangeConfig: Codable {
    var dayOfWeek: Int  // 0 is Monday, 1 is Tuesday, and so on
    var startTime: Date
    var endTime: Date
}

typealias UserDocument = AppwriteModels.Document<UserModel>
