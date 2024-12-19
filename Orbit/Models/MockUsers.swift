//
//  MockUsers.swift
//  Orbit
//
//  Created by Nathaniel D'Orazio on 2024-12-18.
//

import Foundation

extension UserModel {
    static func mockUsers() -> [UserModel] {
        return [
            UserModel(
                accountId: "user1",
                name: "Sarah Chen",
                interests: ["Photography", "Hiking", "Coffee", "Art", "Travel"],
                isInterestedToMeet: true,
                profilePictureUrl: "https://picsum.photos/200",
                personalPreferences: PersonalPreferences(
                    activitiesHobbies: ["Photography", "Hiking", "Art"],
                    friendActivities: ["Creative Collaborator", "Travel Buddy"]
                ),
                socialStyle: SocialStyleModel(
                    mySocialStyle: ["Extroverted", "Spontaneous", "Creative"],
                    feelAfterMeetup: "Energized"
                ),
                interactionPreferences: InteractionPreferencesModel(
                    events: ["Grab a coffee together", "Try an outdoor adventure"],
                    topics: ["Art", "Travel", "Photography"]
                ),
                friendshipValues: FriendshipValuesModel(
                    values: ["Authenticity", "Adventure", "Growth"],
                    idealFriendship: ["Spontaneous", "Creative"],
                    qualities: ["Open-minded", "Adventurous"]
                ),
                socialSituations: SocialSituationsModel(
                    feelWhenMeetingNewPeople: "Excited and Energized",
                    socialRole: "The Social Butterfly"
                ),
                hasCompletedOnboarding: true
            ),
            UserModel(
                accountId: "user2",
                name: "Alex Rivera",
                interests: ["Gaming", "Tech", "Music", "Movies", "Cooking"],
                isInterestedToMeet: true,
                profilePictureUrl: "https://picsum.photos/201",
                personalPreferences: PersonalPreferences(
                    activitiesHobbies: ["Gaming", "Coding", "Music"],
                    friendActivities: ["Hobby Buddy", "Deep Conversations"]
                ),
                socialStyle: SocialStyleModel(
                    mySocialStyle: ["Ambivert", "Strategic", "Analytical"],
                    feelAfterMeetup: "Reflective"
                ),
                interactionPreferences: InteractionPreferencesModel(
                    events: ["Share a meal", "Enjoy hobbies together"],
                    topics: ["Tech", "Gaming", "Movies"]
                ),
                friendshipValues: FriendshipValuesModel(
                    values: ["Loyalty", "Shared Interests", "Fun"],
                    idealFriendship: ["Intellectual", "Relaxed"],
                    qualities: ["Tech-savvy", "Analytical"]
                ),
                socialSituations: SocialSituationsModel(
                    feelWhenMeetingNewPeople: "Curious",
                    socialRole: "The Observer"
                ),
                hasCompletedOnboarding: true
            ),
            UserModel(
                accountId: "user3",
                name: "Jordan Taylor",
                interests: ["Fitness", "Reading", "Meditation", "Yoga", "Writing"],
                isInterestedToMeet: true,
                profilePictureUrl: "https://picsum.photos/202",
                personalPreferences: PersonalPreferences(
                    activitiesHobbies: ["Yoga", "Reading", "Meditation"],
                    friendActivities: ["Workout Partner", "Deep Conversations"]
                ),
                socialStyle: SocialStyleModel(
                    mySocialStyle: ["Introspective", "Calm", "Thoughtful"],
                    feelAfterMeetup: "Reflective"
                ),
                interactionPreferences: InteractionPreferencesModel(
                    events: ["Enjoy hobbies together", "Share a meal"],
                    topics: ["Books", "Wellness", "Personal Growth"]
                ),
                friendshipValues: FriendshipValuesModel(
                    values: ["Personal Growth", "Understanding", "Support"],
                    idealFriendship: ["Mindful", "Supportive"],
                    qualities: ["Self-aware", "Calm"]
                ),
                socialSituations: SocialSituationsModel(
                    feelWhenMeetingNewPeople: "Reserved but Interested",
                    socialRole: "The Listener"
                ),
                hasCompletedOnboarding: true
            )
        ]
    }
}

