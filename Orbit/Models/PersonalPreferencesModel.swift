//
//  PersonalPreferencesModel.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-12-18.
//

import Foundation

struct PersonalPreferences: Codable, Equatable {
    var activitiesHobbies: [String]
    var friendActivities: [String]
}
