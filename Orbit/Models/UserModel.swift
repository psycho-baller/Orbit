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
    let id: String
    let accountId: String
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

    //    var requestedMeetupIds: [String]?  // Relationship with meetups
    //    var approvedMeetupIds: [String]?  // Relationship with approvals
    var requestedMeetups: [MeetupRequestModel]?  // Relationship with meetups
    var approvedMeetups: [MeetupApprovalModel]?  // Relationship with approvals

    // New Attributes
    var showLastOnline: Bool = true
    var showJoinedDate: Bool = true
    var showSentReceivedRatio: Bool = true
    var lastOnline: String?  // ISO8601 formatted date-time (optional)

    // Newly added attributes from the database
    var userLanguages: [UserLanguageModel]?
    var gender: UserGender?
    var pronouns: [UserPronouns]
    var showStarSign: Bool = true
    var userLinks: [UserLinkModel]?
    var intentions: [UserIntention]?

    // Define CodingKeys to map "$id" to "id"
    enum CodingKeys: String, CodingKey {
        case id = "$id"
        case accountId, username, firstName, lastName, interests, conversations,
            currentAreaId
        case profilePictureUrl, bio, dob
        case personalPreferences, interactionPreferences, friendshipValues,
            hasCompletedOnboarding
        case requestedMeetups, approvedMeetups
        case showLastOnline, showJoinedDate, showSentReceivedRatio, lastOnline
        case userLanguages, gender, pronouns, showStarSign, userLinks,
            intentions
    }
    static func == (lhs: UserModel, rhs: UserModel) -> Bool {
        return lhs.accountId == rhs.accountId
    }

    init(
        id: String = UUID().uuidString,
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

        //        requestedMeetupIds: [String]? = nil,
        //        approvedMeetupIds: [String]? = nil,
        requestedMeetups: [MeetupRequestModel]? = nil,
        approvedMeetups: [MeetupApprovalModel]? = nil,

        /// newly added attributes
        lastOnline: String? = nil,
        userLanguages: [UserLanguageModel]? = nil,
        gender: UserGender? = nil,
        pronouns: [UserPronouns] = [],
        showStarSign: Bool = true,
        userLinks: [UserLinkModel]? = nil,
        intentions: [UserIntention]? = nil
    ) {
        self.id = id
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
        self.requestedMeetups = requestedMeetups
        self.approvedMeetups = approvedMeetups
        //        self.requestedMeetupIds = requestedMeetupIds
        //        self.approvedMeetupIds = approvedMeetupIds
        self.lastOnline = lastOnline
        self.userLanguages = userLanguages
        self.gender = gender
        self.pronouns = pronouns
        self.showStarSign = showStarSign
        self.userLinks = userLinks
        self.intentions = intentions
    }

    func toJson(excludeId: Bool = false) -> [String: Any] {
        var json =
            try! JSONSerialization.jsonObject(
                with: JSONEncoder().encode(self),
                options: []
            ) as! [String: Any]

        if excludeId {
            json.removeValue(forKey: "$id")  // ✅ Remove Appwrite's `$id`
        }

        return json
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
        //        requestedMeetupIds: [String]? = nil,
        //        approvedMeetupIds: [String]? = nil,
        requestedMeetups: [MeetupRequestModel]? = nil,
        meetupsApproved: [MeetupApprovalModel]? = nil,
        lastOnline: String? = nil,
        userLanguages: [UserLanguageModel]? = nil,
        gender: UserGender? = nil,
        pronouns: [UserPronouns]? = nil,
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
            //            requestedMeetupIds: requestedMeetupIds ?? self.requestedMeetupIds,
            //            approvedMeetupIds: approvedMeetupIds ?? self.approvedMeetupIds,
            requestedMeetups: requestedMeetups ?? self.requestedMeetups,
            approvedMeetups: approvedMeetups ?? self.approvedMeetups,
            lastOnline: lastOnline ?? self.lastOnline,
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
            accountId: "imjustken",
            username: "imjustken",
            firstName: "Ken",
            lastName: "",
            interests: [
                "Fitness", "Reading", "Meditation", "Writing", "Hiking",
            ],
            profilePictureUrl: "https://picsum.photos/200",
            bio:
                "I love photography, hiking, and art. I'm also a big fan of travel!",
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
            //            requestedMeetups: [MeetupRequestModel.mock()],
            //            approvedMeetups: [MeetupApprovalModel.mock()],
            lastOnline: "2024-02-20T15:30:00Z",
            gender: .man,
            pronouns: [.heHim],
            userLinks: [
                .mock()
            ],
            intentions: [
                .friendships,
                .conversations,
                .hobbies,
            ]
        )
    }

    static func mock2() -> UserModel {
        UserModel(
            accountId: "user2",
            username: "slingshot69",
            firstName: "Mark",
            lastName: "",
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
            //            requestedMeetups: [MeetupRequestModel.mock()],
            //            approvedMeetups: [],
            lastOnline: "2024-02-19T10:45:00Z"
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
            //            requestedMeetups: [],
            //            approvedMeetups: [MeetupApprovalModel.mock()],
            lastOnline: "2024-02-18T20:15:00Z"
        )
    }

    static func mockNoPendingMeetups() -> UserModel {
        UserModel(
            accountId: "slingshot69",
            username: "slingshot69",
            firstName: "Mark",
            lastName: "",
            interests: ["Fitness", "Reading", "Meditation", "Yoga", "Writing"],
            profilePictureUrl: "https://picsum.photos/202",
            bio:
                "Curious, open-minded, and always up for a good conversation. I enjoy meeting new people, learning from different perspectives, and making the most of every experience",
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
            gender: .man,
            pronouns: [.heHim],
            userLinks: [
                .mock()
            ],
            intentions: [
                .friendships,
                .conversations,
                .hobbies,
            ]
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
    case preferNotToSay = "Prefer not to say"
    case other
}

enum UserPronouns: String, Codable {
    case heHim = "he/him"
    case sheHer = "she/her"
    case theyThem = "they/them"
    //    case other
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
