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

    // 🔹 New Attributes
    var showLastOnline: Bool = true
    var showJoinedDate: Bool = true
    var showSentReceivedRatio: Bool = true
    var lastOnline: String?  // 🔹 ISO8601 formatted date-time (optional)
    var requestedMeetups: [MeetupRequestModel]?  // 🔹 Relationship with meetups
    var meetupsApproved: [MeetupApprovalModel]?  // 🔹 Relationship with approvals

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
        meetupsApproved: [MeetupApprovalModel]? = nil
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
        meetupsApproved: [MeetupApprovalModel]? = nil
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
            meetupsApproved: meetupsApproved ?? self.meetupsApproved
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
            interactionPreferences: InteractionPreferencesModel(
                events: ["Grab a coffee together", "Try an outdoor adventure"],
                topics: ["Art", "Travel", "Photography"]
            ),
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
            interactionPreferences: InteractionPreferencesModel(
                events: ["Share a meal", "Enjoy hobbies together"],
                topics: ["Tech", "Gaming", "Movies"]
            ),
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
            interactionPreferences: InteractionPreferencesModel(
                events: ["Enjoy hobbies together", "Share a meal"],
                topics: ["Books", "Wellness", "Personal Growth"]
            ),
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
                interactionPreferences: InteractionPreferencesModel(
                    events: ["Share a meal", "Enjoy hobbies together"],
                    topics: ["Tech", "Gaming", "Movies"]
                ),
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
                interactionPreferences: InteractionPreferencesModel(
                    events: ["Enjoy hobbies together", "Share a meal"],
                    topics: ["Books", "Wellness", "Personal Growth"]
                ),
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

typealias UserDocument = AppwriteModels.Document<UserModel>

extension UserDocument {
    static func mock() -> UserDocument {
        return AppwriteModels.Document<UserModel>.mock(
            data: UserModel.mock()
        )
    }
}
