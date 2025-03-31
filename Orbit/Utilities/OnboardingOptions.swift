//
//  OnboardingOptions.swift
//  Orbit
//
//  Created by Nathaniel D'Orazio on 2025-03-31.
//

import Foundation

/// Centralized storage for all onboarding options to ensure consistency across the app
struct OnboardingOptions {
    // Activities & Hobbies
    static let activitiesHobbies: [String] = [
        "Hiking", "Reading", "Writing", "Cooking", "Volunteering",
        "Photography", "Yoga", "Gaming", "Painting", "Sports",
        "Traveling", "Coding", "Music", "Meditation", "Dancing",
        "Gardening", "Climbing", "Crochet", "Skateboarding", "Debating",
        "Snow Sports", "Water Sports", "Racket Sports", "Board Games",
        "Martial Arts", "Collecting", "Language Learning", "Journaling",
        "Golf", "Extreme Sports", "Ball Sports"
    ]
    
    // Friend Activities
    static let friendActivities: [String] = [
        "Workout Partner", "Travel Buddy", "Study Partner",
        "Creative Collaborator", "Hobby Buddy", "Event Companion",
        "Group Hangouts", "Casual Meetup", "Deep Conversations",
        "Reliability Partner"
    ]
    
    // Preferred Meetup Types
    static let preferredMeetupType: [String] = [
        "Grab a coffee together", "Share a meal", "Enjoy hobbies together",
        "Try an outdoor adventure", "Play or participate in sports activities",
        "Practice speaking a new language"
    ]
    
    // Conversation Topics
    static let convoTopics: [String] = [
        "Books", "Movies", "Tech", "Philosophy", "Psychology",
        "Wellness", "Personal Growth", "Sports", "Fitness",
        "Relationships", "Spirituality", "Health", "Current Events",
        "Culture", "Food", "Travel", "Music", "Art", "Fashion",
        "Gaming", "Nature", "Animals", "Career", "Education",
        "Politics", "Social Issues", "Entrepreneurship", "History"
    ]
    
    // Friendship Values
    static let friendshipValues: [String] = [
        "Deep Conversations", "Adventure", "Humor", "Loyalty",
        "Honesty", "Kindness", "Respect", "Similar Interests",
        "Mutual Support"
    ]
    
    // Friendship Qualities
    static let friendshipQualities: [String] = [
        "Good Listener", "Outgoing", "Empathetic", "Reliable",
        "Intelligent", "Creative", "Curious", "Funny", "Open-Minded",
        "Positive", "Thoughtful", "Passionate", "Ambitious", "Adventurous"
    ]
    
    // User Intentions
    static let intentions: [String] = UserIntention.allCases.map { $0.rawValue }
}
