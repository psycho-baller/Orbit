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
    var profilePictureUrl: String?
    var bio: String?
    var dob: String?  // Date of birth

    // Onboarding-related fields
    //    var personalPreferences: PersonalPreferences?
    var activitiesHobbies: [String]?
    var friendActivities: [String]?
    //    var interactionPreferences: InteractionPreferencesModel?
    var preferredMeetupType: [String]?
    var convoTopics: [String]?
    var preferredMinAge: Int?
    var preferredMaxAge: Int?
    var preferredGender: [UserGender]?
    //    var friendshipValues: FriendshipValuesModel?
    var friendshipValues: [String]?
    var friendshipQualities: [String]?
    var hasCompletedOnboarding: Bool = false

    //    var requestedMeetupIds: [String]?  // Relationship with meetups
    //    var approvedMeetupIds: [String]?  // Relationship with approvals
    var requestedMeetups: [MeetupRequestModel]? = []  // Relationship with meetups
    var createdChats: [ChatModel]? = []  // Chats where the user was the chat creator
    var otherChats: [ChatModel]? = []  // Chats where the user was the one who created the post

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
    var myBlocks: [UserBlockModel]? = []
    var blockedMe: [UserBlockModel]? = []
    var myReports: [UserReportModel]? = []
    var reportedMe: [UserReportModel]? = []
    var otherGender: String?

    // Display settings for the user's profile
    var showAge: Bool = true
    var showPronouns: Bool = true
    var showGender: Bool = true

    // New property for featured interests
    var featuredInterests: [String]?

    // Define CodingKeys to map "$id" to "id"
    enum CodingKeys: String, CodingKey {
        case id = "$id"
        case accountId, username, firstName, lastName
        case profilePictureUrl, bio, dob
        case activitiesHobbies, friendActivities, preferredMeetupType,
            convoTopics,
            preferredMinAge, preferredMaxAge, preferredGender, friendshipValues,
            friendshipQualities, hasCompletedOnboarding
        case requestedMeetups, createdChats, otherChats
        case showLastOnline, showJoinedDate, showSentReceivedRatio, lastOnline
        case userLanguages, gender, pronouns, showStarSign, userLinks,
            intentions
        case myBlocks, blockedMe, myReports, reportedMe
        case otherGender
        case featuredInterests
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
        profilePictureUrl: String? = nil,
        bio: String? = nil,
        dob: String? = nil,

        /// onboarding stuff
        activitiesHobbies: [String]? = nil,
        friendActivities: [String]? = nil,
        preferredMeetupType: [String]? = nil,
        convoTopics: [String]? = nil,
        preferredMinAge: Int? = nil,
        preferredMaxAge: Int? = nil,
        preferredGender: [UserGender]? = nil,
        friendshipValues: [String]? = nil,
        friendshipQualities: [String]? = nil,

        hasCompletedOnboarding: Bool = false,

        /// personal prefs
        showLastOnline: Bool = true,
        showJoinedDate: Bool = true,
        showSentReceivedRatio: Bool = true,

        //        requestedMeetupIds: [String]? = nil,
        //        approvedMeetupIds: [String]? = nil,
        requestedMeetups: [MeetupRequestModel]? = [],
        createdChats: [ChatModel]? = [],
        otherChats: [ChatModel]? = [],

        /// newly added attributes
        lastOnline: String? = nil,
        userLanguages: [UserLanguageModel]? = nil,
        gender: UserGender? = nil,
        pronouns: [UserPronouns] = [],
        showStarSign: Bool = true,
        userLinks: [UserLinkModel]? = nil,
        intentions: [UserIntention]? = nil,
        featuredInterests: [String]? = nil,
        myBlocks: [UserBlockModel]? = [],
        blockedMe: [UserBlockModel]? = [],
        myReports: [UserReportModel]? = [],
        reportedMe: [UserReportModel]? = [],
        otherGender: String? = nil
    ) {
        self.id = id
        self.accountId = accountId
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.profilePictureUrl = profilePictureUrl
        self.bio = bio
        self.dob = dob

        /// onboarding stuff
        self.activitiesHobbies = activitiesHobbies
        self.friendActivities = friendActivities
        self.preferredMeetupType = preferredMeetupType
        self.convoTopics = convoTopics
        self.preferredMinAge = preferredMinAge
        self.preferredMaxAge = preferredMaxAge
        self.preferredGender = preferredGender
        self.friendshipValues = friendshipValues
        self.friendshipQualities = friendshipQualities

        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.showLastOnline = showLastOnline
        self.showJoinedDate = showJoinedDate
        self.showSentReceivedRatio = showSentReceivedRatio
        self.requestedMeetups = requestedMeetups
        self.createdChats = createdChats
        self.otherChats = otherChats
        self.lastOnline = lastOnline
        self.userLanguages = userLanguages
        self.gender = gender
        self.pronouns = pronouns
        self.showStarSign = showStarSign
        self.userLinks = userLinks
        self.intentions = intentions
        self.myBlocks = myBlocks
        self.blockedMe = blockedMe
        self.myReports = myReports
        self.reportedMe = reportedMe
        self.otherGender = otherGender
        self.featuredInterests = featuredInterests
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

        // Convert `intentions` enum list to a short-form array of strings
        if let userIntentions = self.intentions {
            json["intentions"] = userIntentions.map { $0.rawValue }
        }
        json["preferredGender"] = self.preferredGender?.map { $0.rawValue }
        json["createdChats"] = self.createdChats?.map(\.id)
        json["otherChats"] = self.otherChats?.map(\.id)

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
        /// onboarding stuff
        activitiesHobbies: [String]? = nil,
        friendActivities: [String]? = nil,
        preferredMeetupType: [String]? = nil,
        convoTopics: [String]? = nil,
        preferredMinAge: Int? = nil,
        preferredMaxAge: Int? = nil,
        preferredGender: [UserGender]? = nil,
        friendshipValues: [String]? = nil,
        friendshipQualities: [String]? = nil,
        showLastOnline: Bool? = nil,
        showJoinedDate: Bool? = nil,
        showSentReceivedRatio: Bool? = nil,
        requestedMeetups: [MeetupRequestModel]? = nil,
        createdChats: [ChatModel]? = nil,
        otherChats: [ChatModel]? = nil,
        lastOnline: String? = nil,
        userLanguages: [UserLanguageModel]? = nil,
        gender: UserGender? = nil,
        pronouns: [UserPronouns]? = nil,
        showStarSign: Bool? = nil,
        userLinks: [UserLinkModel]? = nil,
        intentions: [UserIntention]? = nil,
        featuredInterests: [String]? = nil,
        myBlocks: [UserBlockModel]? = nil,
        blockedMe: [UserBlockModel]? = nil,
        myReports: [UserReportModel]? = nil,
        reportedMe: [UserReportModel]? = nil,
        otherGender: String? = nil
    ) -> UserModel {
        return UserModel(
            accountId: self.accountId,
            username: username ?? self.username,
            firstName: firstName ?? self.firstName,
            lastName: lastName ?? self.lastName,
            profilePictureUrl: self.profilePictureUrl,
            bio: bio ?? self.bio,
            dob: dob ?? self.dob,
            /// onboarding stuff
            activitiesHobbies: activitiesHobbies ?? self.activitiesHobbies,
            friendActivities: friendActivities ?? self.friendActivities,
            preferredMeetupType: preferredMeetupType
                ?? self.preferredMeetupType,
            convoTopics: convoTopics ?? self.convoTopics,
            preferredMinAge: preferredMinAge ?? self.preferredMinAge,
            preferredMaxAge: preferredMaxAge ?? self.preferredMaxAge,
            preferredGender: preferredGender ?? self.preferredGender,
            friendshipValues: friendshipValues ?? self.friendshipValues,
            friendshipQualities: friendshipQualities
                ?? self.friendshipQualities,
            hasCompletedOnboarding: self.hasCompletedOnboarding,
            showLastOnline: showLastOnline ?? self.showLastOnline,
            showJoinedDate: showJoinedDate ?? self.showJoinedDate,
            showSentReceivedRatio: showSentReceivedRatio
                ?? self.showSentReceivedRatio,
            requestedMeetups: requestedMeetups ?? self.requestedMeetups,
            createdChats: createdChats ?? self.createdChats,
            otherChats: otherChats ?? self.otherChats,
            lastOnline: lastOnline ?? self.lastOnline,
            userLanguages: userLanguages ?? self.userLanguages,
            gender: gender ?? self.gender,
            pronouns: pronouns ?? self.pronouns,
            showStarSign: showStarSign ?? self.showStarSign,
            userLinks: userLinks ?? self.userLinks,
            intentions: intentions ?? self.intentions,
            featuredInterests: featuredInterests ?? self.featuredInterests,
            myBlocks: myBlocks ?? self.myBlocks,
            blockedMe: blockedMe ?? self.blockedMe,
            myReports: myReports ?? self.myReports,
            reportedMe: reportedMe ?? self.reportedMe,
            otherGender: otherGender ?? self.otherGender
        )
    }

    static func mock() -> UserModel {
        UserModel(
            id: "imjustken",
            accountId: "imjustken",
            username: "imjustken",
            firstName: "Ken",
            lastName: "",
            profilePictureUrl: "https://picsum.photos/200",
            bio:
                "I love photography, hiking, and art. I'm also a big fan of travel!",
            dob: "1995-06-15",
            /// onboarding stuff
            activitiesHobbies: ["Photography", "Hiking", "Art"],
            friendActivities: ["Creative Collaborator", "Travel Buddy"],
            preferredMeetupType: ["Photography Exhibition", "Hiking Trip"],
            convoTopics: ["Photography", "Hiking", "Art"],
            preferredMinAge: 18,
            preferredMaxAge: 30,
            preferredGender: [.man],
            friendshipValues: ["Authenticity", "Adventure", "Growth"],
            friendshipQualities: ["Open-minded", "Adventurous"],
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
            ],
            featuredInterests: ["Photography", "Hiking", "Art"]
        )
    }

    static func mock2() -> UserModel {
        UserModel(
            id: "user2",
            accountId: "user2",
            username: "slingshot69",
            firstName: "Mark",
            lastName: "",
            profilePictureUrl: "https://picsum.photos/201",
            bio: "I'm just a chill dude",
            dob: "1995-06-15",
            /// onboarding stuff
            activitiesHobbies: ["Gaming", "Coding", "Music"],
            friendActivities: ["Hobby Buddy", "Deep Conversations"],
            preferredMeetupType: ["Tech Meetups", "Hiking Trips"],
            convoTopics: ["AI", "Space Exploration"],
            preferredMinAge: 20,
            preferredMaxAge: 35,
            preferredGender: [.man, .woman],
            friendshipValues: ["Authenticity", "Adventure", "Growth"],
            friendshipQualities: ["Open-minded", "Adventurous"],
            hasCompletedOnboarding: true,
            showLastOnline: false,
            showJoinedDate: true,
            showSentReceivedRatio: false,
            //            requestedMeetups: [MeetupRequestModel.mock()],
            //            approvedMeetups: [],
            lastOnline: "2024-02-19T10:45:00Z",
            gender: .other,
            pronouns: [.heHim],
            userLinks: [
                .mock()
            ],
            intentions: [
                .friendships,
                .conversations,
                .hobbies,
            ],
            featuredInterests: ["Gaming", "Tech", "Music"],
            otherGender: "Cat woman"
        )
    }

    static func mock3() -> UserModel {
        UserModel(
            id: "user3",
            accountId: "user3",
            username: "jordan_taylor",
            firstName: "Jordan",
            lastName: "Taylor",
            profilePictureUrl: "https://picsum.photos/202",
            bio: "I'm just a chill dude",
            /// onboarding stuff
            activitiesHobbies: ["Yoga", "Reading", "Meditation"],
            friendActivities: ["Workout Partner", "Deep Conversations"],
            preferredMeetupType: ["Tech Meetups", "Hiking Trips"],
            convoTopics: ["AI", "Startups", "Philosophy"],
            preferredMinAge: 20,
            preferredMaxAge: 35,
            preferredGender: [.man, .woman],
            friendshipValues: ["Authenticity", "Adventure", "Growth"],
            friendshipQualities: ["Open-minded", "Adventurous"],
            hasCompletedOnboarding: true,
            showLastOnline: true,
            showJoinedDate: false,
            showSentReceivedRatio: true,
            //            requestedMeetups: [],
            //            approvedMeetups: [MeetupApprovalModel.mock()],
            lastOnline: "2024-02-18T20:15:00Z",
            featuredInterests: ["Yoga", "Reading", "Meditation"],
            otherGender: nil
        )
    }

    static func mockNoPendingMeetups() -> UserModel {
        UserModel(
            id: "slingshot69",
            accountId: "slingshot69",
            username: "slingshot69",
            firstName: "Mark",
            lastName: "",
            profilePictureUrl: "https://picsum.photos/202",
            bio:
                "Curious, open-minded, and always up for a good conversation. I enjoy meeting new people, learning from different perspectives, and making the most of every experience",
            // personalPreferences: PersonalPreferences(
            //     activitiesHobbies: ["Yoga", "Reading", "Meditation"],
            //     friendActivities: ["Workout Partner", "Deep Conversations"]
            // ),
            // interactionPreferences: .mock(),
            // friendshipValues: FriendshipValuesModel(
            //     friendshipValues: ["Personal Growth", "Understanding", "Support"],
            //     friendshipQualities: ["Self-aware", "Calm"]
            // ),
            /// onboarding stuff
            activitiesHobbies: ["Yoga", "Reading", "Meditation"],
            friendActivities: ["Workout Partner", "Deep Conversations"],
            preferredMeetupType: ["Tech Meetups", "Hiking Trips"],
            convoTopics: ["AI", "Startups", "Philosophy"],
            preferredMinAge: 20,
            preferredMaxAge: 35,
            preferredGender: [.man, .woman],
            friendshipValues: ["Authenticity", "Adventure", "Growth"],
            friendshipQualities: ["Open-minded", "Adventurous"],
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
            ],
            featuredInterests: ["Yoga", "Reading", "Meditation"],
            otherGender: nil
        )
    }

    static func mockUsers() -> [UserModel] {
        return [
            .mock(),
            .mock2(),
            .mock3(),
            UserModel(
                id: "user4",
                accountId: "user4",
                username: "alexrivera42",
                firstName: "Alex",
                lastName: "Rivera",
                profilePictureUrl: "https://picsum.photos/201",
                // personalPreferences: PersonalPreferences(
                //     activitiesHobbies: ["Gaming", "Coding", "Music"],
                //     friendActivities: ["Hobby Buddy", "Deep Conversations"]
                // ),
                // interactionPreferences: .mock(),
                // friendshipValues: FriendshipValuesModel(
                //     friendshipValues: ["Loyalty", "Shared Interests", "Fun"],
                //     friendshipQualities: ["Tech-savvy", "Analytical"]
                // ),
                /// onboarding stuff
                activitiesHobbies: ["Gaming", "Coding", "Music"],
                friendActivities: ["Hobby Buddy", "Deep Conversations"],
                preferredMeetupType: ["Tech Meetups", "Hiking Trips"],
                convoTopics: ["AI", "Space Exploration"],
                preferredMinAge: 20,
                preferredMaxAge: 35,
                preferredGender: [.man, .woman],
                friendshipValues: ["Authenticity", "Adventure", "Growth"],
                friendshipQualities: ["Open-minded", "Adventurous"],
                hasCompletedOnboarding: true,
                featuredInterests: ["Gaming", "Tech", "Music"],
                otherGender: nil
            ),
            UserModel(
                id: "user5",
                accountId: "user5",
                username: "noob",
                firstName: "Klay",
                lastName: "Blampson",
                profilePictureUrl: "https://picsum.photos/202",
                // personalPreferences: PersonalPreferences(
                //     activitiesHobbies: ["Yoga", "Reading", "Meditation"],
                //     friendActivities: ["Workout Partner", "Deep Conversations"]
                // ),
                // interactionPreferences: .mock(),
                // friendshipValues: FriendshipValuesModel(
                //     friendshipValues: ["Personal Growth", "Understanding", "Support"],
                //     friendshipQualities: ["Self-aware", "Calm"]
                // ),
                /// onboarding stuff
                activitiesHobbies: ["Yoga", "Reading", "Meditation"],
                friendActivities: ["Workout Partner", "Deep Conversations"],
                preferredMeetupType: ["Tech Meetups", "Hiking Trips"],
                convoTopics: ["AI", "Space Exploration"],
                preferredMinAge: 20,
                preferredMaxAge: 35,
                preferredGender: [.man, .woman],
                friendshipValues: ["Authenticity", "Adventure", "Growth"],
                friendshipQualities: ["Open-minded", "Adventurous"],
                hasCompletedOnboarding: true,
                featuredInterests: ["Yoga", "Reading", "Meditation"],
                otherGender: nil
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
    //    case preferNotToSay = "Prefer not to say"
    case other
}

enum UserPronouns: String, Codable {
    case heHim = "he/him"
    case sheHer = "she/her"
    case theyThem = "they/them"
    //    case other
}

enum UserIntention: String, Codable, CaseIterable {
    case hobbies = "hobbies"
    case conversations = "conversations"
    case friendships = "friendships"
    case dating = "dating"
    case exploring = "exploring"

    /// Display-friendly description
    var description: String {
        switch self {
        case .hobbies:
            return "Making friends who share my interests and hobbies"
        case .conversations:
            return "Having meaningful conversations and deep discussions"
        case .friendships: return "Building long-term friendships"
        case .dating: return "Exploring romantic relationships"
        case .exploring: return "Idk, I'm just a chill guy"
        }
    }
    init?(description: String) {
        guard
            let match = UserIntention.allCases.first(where: {
                $0.description == description
            })
        else {
            return nil
        }
        self = match
    }
}

typealias UserDocument = AppwriteModels.Document<UserModel>

extension UserDocument {
    static func mock() -> UserDocument {
        return AppwriteModels.Document<UserModel>.mock(
            data: UserModel.mock()
        )
    }
}
