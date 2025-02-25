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

struct UserModel: Codable, Identifiable, Equatable, CodableDictionaryConvertible
{
    let accountId: String
    var id: String { accountId }
    var username: String
    var firstName: String
    var lastName: String?
    var interests: [String]?
    var conversations: [String]?
    var currentAreaId: String?  // References Area collection
    var profilePictureUrl: String?
    var bio: String?
    var dob: String?  // Date of birth

    // Onboarding-related fields
    var personalPreferences: PersonalPreferences?
    var interactionPreferences: InteractionPreferencesModel?
    var friendshipValues: FriendshipValuesModel?
    var hasCompletedOnboarding: Bool? = false

    // New Attributes
    var showLastOnline: Bool = true
    var showJoinedDate: Bool = true
    var showSentReceivedRatio: Bool = true
    var lastOnline: String?  // ISO8601 formatted date-time (optional)
    var requestedMeetups: [MeetupRequestModel]?  // Relationship with meetups
    var meetupsApproved: [MeetupApprovalModel]?  // Relationship with approvals

    // Newly added attributes from the database
    var userLanguages: [UserLanguageModel]?
    var gender: UserGender?
    var pronouns: UserPronouns?
    var showStarSign: Bool = true
    var userLinks: [UserLinkModel]?
    var intentions: [UserIntention]?

    static func == (lhs: UserModel, rhs: UserModel) -> Bool {
        return lhs.accountId == rhs.accountId
    }

    init(
        accountId: String,
        username: String,
        firstName: String,
        lastName: String? = nil,
        interests: [String]? = nil,
        conversations: [String]? = nil,
        currentAreaId: String? = nil,
        profilePictureUrl: String? = nil,
        bio: String? = nil,
        dob: String? = nil,

        /// onboarding stuff
        personalPreferences: PersonalPreferences? = nil,
        interactionPreferences: InteractionPreferencesModel? = nil,
        friendshipValues: FriendshipValuesModel? = nil,
        hasCompletedOnboarding: Bool? = false,

        /// personal prefs
        showLastOnline: Bool = true,
        showJoinedDate: Bool = true,
        showSentReceivedRatio: Bool = true,
        lastOnline: String? = nil,

        requestedMeetups: [MeetupRequestModel]? = nil,
        meetupsApproved: [MeetupApprovalModel]? = nil,

        /// newly added attributes
        userLanguages: [UserLanguageModel]? = nil,
        gender: UserGender? = nil,
        pronouns: UserPronouns? = nil,
        showStarSign: Bool = true,
        userLinks: [UserLinkModel]? = nil,
        intentions: [UserIntention]? = nil
    ) {
        self.accountId = accountId
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.interests = interests
        self.conversations = conversations
        self.currentAreaId = currentAreaId
        self.profilePictureUrl = profilePictureUrl
        self.bio = bio
        self.dob = dob
        self.personalPreferences = personalPreferences
        self.interactionPreferences = interactionPreferences
        self.friendshipValues = friendshipValues
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.showLastOnline = showLastOnline
        self.showJoinedDate = showJoinedDate
        self.showSentReceivedRatio = showSentReceivedRatio
        self.lastOnline = lastOnline
        self.requestedMeetups = requestedMeetups
        self.meetupsApproved = meetupsApproved
        self.userLanguages = userLanguages
        self.gender = gender
        self.pronouns = pronouns
        self.showStarSign = showStarSign
        self.userLinks = userLinks
        self.intentions = intentions
    }

    func update(
        username: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        interests: [String]? = nil,
        conversations: [String]? = nil,
        bio: String? = nil,
        dob: String? = nil,
        personalPreferences: PersonalPreferences? = nil,
        interactionPreferences: InteractionPreferencesModel? = nil,
        friendshipValues: FriendshipValuesModel? = nil,
        showLastOnline: Bool? = nil,
        showJoinedDate: Bool? = nil,
        showSentReceivedRatio: Bool? = nil,
        lastOnline: String? = nil,
        requestedMeetups: [MeetupRequestModel]? = nil,
        meetupsApproved: [MeetupApprovalModel]? = nil,
        userLanguages: [UserLanguageModel]? = nil,
        gender: UserGender? = nil,
        pronouns: UserPronouns? = nil,
        showStarSign: Bool? = nil,
        userLinks: [UserLinkModel]? = nil,
        intentions: [UserIntention]? = nil
    ) -> UserModel {
        return UserModel(
            accountId: self.accountId,
            username: username ?? self.username,
            firstName: firstName ?? self.firstName,
            lastName: lastName ?? self.lastName,
            interests: interests ?? self.interests,
            conversations: conversations ?? self.conversations,
            currentAreaId: self.currentAreaId,
            profilePictureUrl: self.profilePictureUrl,
            bio: bio ?? self.bio,
            dob: dob ?? self.dob,
            personalPreferences: personalPreferences
                ?? self.personalPreferences,
            interactionPreferences: interactionPreferences
                ?? self.interactionPreferences,
            friendshipValues: friendshipValues ?? self.friendshipValues,
            hasCompletedOnboarding: self.hasCompletedOnboarding,
            showLastOnline: showLastOnline ?? self.showLastOnline,
            showJoinedDate: showJoinedDate ?? self.showJoinedDate,
            showSentReceivedRatio: showSentReceivedRatio
                ?? self.showSentReceivedRatio,
            lastOnline: lastOnline ?? self.lastOnline,
            requestedMeetups: requestedMeetups ?? self.requestedMeetups,
            meetupsApproved: meetupsApproved ?? self.meetupsApproved,
            userLanguages: userLanguages ?? self.userLanguages,
            gender: gender ?? self.gender,
            pronouns: pronouns ?? self.pronouns,
            showStarSign: showStarSign ?? self.showStarSign,
            userLinks: userLinks ?? self.userLinks,
            intentions: intentions ?? self.intentions
        )
    }

    static func mock() -> UserModel {
        UserModel(
            accountId: "user1",
            username: "slingshot69",
            firstName: "Sarah",
            lastName: "Chen",
            interests: ["Photography", "Hiking", "Coffee", "Art", "Travel"],
            profilePictureUrl: "https://picsum.photos/200",
            personalPreferences: PersonalPreferences(
                activitiesHobbies: ["Photography", "Hiking", "Art"],
                friendActivities: ["Creative Collaborator", "Travel Buddy"]
            ),
            interactionPreferences: .mock(),
            friendshipValues: FriendshipValuesModel(
                values: ["Authenticity", "Adventure", "Growth"],
                qualities: ["Open-minded", "Adventurous"]
            ),
            hasCompletedOnboarding: true,
            showLastOnline: true,
            showJoinedDate: true,
            showSentReceivedRatio: true,
            lastOnline: "2024-02-20T15:30:00Z",
            requestedMeetups: [MeetupRequestModel.mock()],
            meetupsApproved: [MeetupApprovalModel.mock()]
        )
    }

    static func mock2() -> UserModel {
        UserModel(
            accountId: "user2",
            username: "imjustken",
            firstName: "Alex",
            lastName: "Rivera",
            interests: ["Gaming", "Tech", "Music", "Movies", "Cooking"],
            profilePictureUrl: "https://picsum.photos/201",
            personalPreferences: PersonalPreferences(
                activitiesHobbies: ["Gaming", "Coding", "Music"],
                friendActivities: ["Hobby Buddy", "Deep Conversations"]
            ),
            interactionPreferences: .mock(),
            friendshipValues: FriendshipValuesModel(
                values: ["Loyalty", "Shared Interests", "Fun"],
                qualities: ["Tech-savvy", "Analytical"]
            ),
            hasCompletedOnboarding: true,
            showLastOnline: false,
            showJoinedDate: true,
            showSentReceivedRatio: false,
            lastOnline: "2024-02-19T10:45:00Z",
            requestedMeetups: [MeetupRequestModel.mock()],
            meetupsApproved: []
        )
    }

    static func mock3() -> UserModel {
        UserModel(
            accountId: "user3",
            username: "jordan_taylor",
            firstName: "Jordan",
            lastName: "Taylor",
            interests: ["Fitness", "Reading", "Meditation", "Yoga", "Writing"],
            profilePictureUrl: "https://picsum.photos/202",
            personalPreferences: PersonalPreferences(
                activitiesHobbies: ["Yoga", "Reading", "Meditation"],
                friendActivities: ["Workout Partner", "Deep Conversations"]
            ),
            interactionPreferences: .mock(),
            friendshipValues: FriendshipValuesModel(
                values: ["Personal Growth", "Understanding", "Support"],
                qualities: ["Self-aware", "Calm"]
            ),
            hasCompletedOnboarding: true,
            showLastOnline: true,
            showJoinedDate: false,
            showSentReceivedRatio: true,
            lastOnline: "2024-02-18T20:15:00Z",
            requestedMeetups: [],
            meetupsApproved: [MeetupApprovalModel.mock()]
        )
    }

    static func mockNoPendingMeetups() -> UserModel {
        UserModel(
            accountId: "user3",
            username: "jordan_taylor",
            firstName: "Jordan",
            lastName: "Taylor",
            interests: ["Fitness", "Reading", "Meditation", "Yoga", "Writing"],
            profilePictureUrl: "https://picsum.photos/202",
            personalPreferences: PersonalPreferences(
                activitiesHobbies: ["Yoga", "Reading", "Meditation"],
                friendActivities: ["Workout Partner", "Deep Conversations"]
            ),
            interactionPreferences: .mock(),
            friendshipValues: FriendshipValuesModel(
                values: ["Personal Growth", "Understanding", "Support"],
                qualities: ["Self-aware", "Calm"]
            ),
            hasCompletedOnboarding: true,
            showLastOnline: true,
            showJoinedDate: false,
            showSentReceivedRatio: true,
            lastOnline: "2024-02-18T20:15:00Z"
        )
    }

    static func mockUsers() -> [UserModel] {
        return [
            .mock(),
            .mock2(),
            .mock3(),
            UserModel(
                accountId: "user4",
                username: "alexrivera42",
                firstName: "Alex",
                lastName: "Rivera",
                interests: ["Gaming", "Tech", "Music", "Movies", "Cooking"],
                profilePictureUrl: "https://picsum.photos/201",
                personalPreferences: PersonalPreferences(
                    activitiesHobbies: ["Gaming", "Coding", "Music"],
                    friendActivities: ["Hobby Buddy", "Deep Conversations"]
                ),
                interactionPreferences: .mock(),
                friendshipValues: FriendshipValuesModel(
                    values: ["Loyalty", "Shared Interests", "Fun"],
                    qualities: ["Tech-savvy", "Analytical"]
                ),
                hasCompletedOnboarding: true
            ),
            UserModel(
                accountId: "user5",
                username: "noob",
                firstName: "Klay",
                lastName: "Blampson",
                interests: [
                    "Fitness", "Reading", "Meditation", "Yoga", "Writing",
                ],
                profilePictureUrl: "https://picsum.photos/202",
                personalPreferences: PersonalPreferences(
                    activitiesHobbies: ["Yoga", "Reading", "Meditation"],
                    friendActivities: ["Workout Partner", "Deep Conversations"]
                ),
                interactionPreferences: .mock(),
                friendshipValues: FriendshipValuesModel(
                    values: ["Personal Growth", "Understanding", "Support"],
                    qualities: ["Self-aware", "Calm"]
                ),
                hasCompletedOnboarding: true
            ),
        ]
    }
}

struct TimeRangeConfig: Codable {
    var dayOfWeek: Int  // 0 is Monday, 1 is Tuesday, and so on
    var startTime: Date
    var endTime: Date
}

enum UserGender: String, Codable, CaseIterable {
    case man
    case woman
    case nonBinary = "non-binary"
    case other
}

enum UserPronouns: String, Codable {
    case heHim = "he/him"
    case sheHer = "she/her"
    case theyThem = "they/them"
    case other
}

enum UserIntention: String, Codable, CaseIterable {
    case hobbies = "Making friends who share my interests and hobbies"
    case conversations = "Having meaningful conversations and deep discussions"
    case friendships = "Building long-term friendships"
    case dating = "Exploring romantic relationships"
    case exploring = "Idk, I'm just a chill guy"
}

typealias UserDocument = AppwriteModels.Document<UserModel>

extension UserDocument {
    static func mock() -> UserDocument {
        return AppwriteModels.Document<UserModel>.mock(
            data: UserModel.mock()
        )
    }
}
