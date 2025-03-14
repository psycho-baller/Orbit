//
//  InteractionPreferencesModel.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-12-18.
//

import Foundation

struct InteractionPreferencesModel: Codable, Equatable {
    let events: [String]?
    let convoTopics: [String]?
    let preferredMinAge: Int?
    let preferredMaxAge: Int?
    let preferredGender: [UserGender]?

    //    init(
    //        events: [String]? = nil,
    //        convoTopics: [String]? = nil,
    //        preferredMinAge: Int? = nil,
    //        preferredMaxAge: Int? = nil,
    //        preferredGender: UserGender? = nil
    //    ) {
    //        self.events = events
    //        self.convoTopics = convoTopics
    //        self.preferredMinAge = preferredMinAge
    //        self.preferredMaxAge = preferredMaxAge
    //        self.preferredGender = preferredGender
    //    }

    static func mock() -> Self {
        return .init(
            events: ["Tech Conferences", "Hackathons"],
            convoTopics: ["AI", "Space Exploration"],
            preferredMinAge: 18,
            preferredMaxAge: 25,
            preferredGender: [.man, .woman]
        )
    }
}
