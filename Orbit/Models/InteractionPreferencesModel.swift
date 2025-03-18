//
//  InteractionPreferencesModel.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-12-18.
//

import Foundation

struct InteractionPreferencesModel: Codable, Equatable {
    let preferredMeetupType: [String]?
    let convoTopics: [String]?
    let preferredMinAge: Int?
    let preferredMaxAge: Int?
    let preferredGender: [UserGender]?

    //    init(
    //        preferredMeetupType: [String]? = nil,
    //        convoTopics: [String]? = nil,
    //        preferredMinAge: Int? = nil,
    //        preferredMaxAge: Int? = nil,
    //        preferredGender: UserGender? = nil
    //    ) {
    //        self.preferredMeetupType = preferredMeetupType
    //        self.convoTopics = convoTopics
    //        self.preferredMinAge = preferredMinAge
    //        self.preferredMaxAge = preferredMaxAge
    //        self.preferredGender = preferredGender
    //    }

    static func mock() -> Self {
        return .init(
            preferredMeetupType: ["Tech Conferences", "Hackathons"],
            convoTopics: ["AI", "Space Exploration"],
            preferredMinAge: 18,
            preferredMaxAge: 25,
            preferredGender: [.man, .woman]
        )
    }
}
