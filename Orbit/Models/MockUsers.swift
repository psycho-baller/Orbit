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
                profileQuestions: [
                    "I love exploring new coffee shops",
                    "Photography is my creative outlet",
                    "Always planning my next adventure"
                ],
                socialStyle: ["Extroverted", "Spontaneous", "Creative"],
                interactionPreferences: ["Small Groups", "One-on-One", "Outdoor Activities"],
                friendshipValues: ["Authenticity", "Adventure", "Growth"],
                socialSituations: ["Coffee Meetups", "Nature Walks", "Art Galleries"],
                lifestylePreferences: ["Early Bird", "Active Lifestyle", "Cultural Events"],
                hasCompletedOnboarding: true
            ),
            UserModel(
                accountId: "user2",
                name: "Alex Rivera",
                interests: ["Gaming", "Tech", "Music", "Movies", "Cooking"],
                isInterestedToMeet: true,
                profilePictureUrl: "https://picsum.photos/201",
                profileQuestions: [
                    "Passionate about game development",
                    "Love hosting dinner parties",
                    "Always up for a movie marathon"
                ],
                socialStyle: ["Ambivert", "Strategic", "Analytical"],
                interactionPreferences: ["Gaming Sessions", "Movie Nights", "Food Tastings"],
                friendshipValues: ["Loyalty", "Shared Interests", "Fun"],
                socialSituations: ["Game Nights", "Movie Screenings", "Cooking Together"],
                lifestylePreferences: ["Night Owl", "Tech-Savvy", "Foodie"],
                hasCompletedOnboarding: true
            ),
            UserModel(
                accountId: "user3",
                name: "Jordan Taylor",
                interests: ["Fitness", "Reading", "Meditation", "Yoga", "Writing"],
                isInterestedToMeet: true,
                profilePictureUrl: "https://picsum.photos/202",
                profileQuestions: [
                    "Wellness and mindfulness enthusiast",
                    "Book club organizer",
                    "Love writing poetry"
                ],
                socialStyle: ["Introspective", "Calm", "Thoughtful"],
                interactionPreferences: ["Quiet Settings", "Deep Conversations", "Wellness Activities"],
                friendshipValues: ["Personal Growth", "Understanding", "Support"],
                socialSituations: ["Book Discussions", "Yoga Classes", "Writing Workshops"],
                lifestylePreferences: ["Balanced Living", "Mindfulness", "Continuous Learning"],
                hasCompletedOnboarding: true
            )
        ]
    }
}

