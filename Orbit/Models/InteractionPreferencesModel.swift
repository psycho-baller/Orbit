//
//  InteractionPreferencesModel.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-12-18.
//

import Foundation

struct InteractionPreferencesModel: Codable, Equatable {
    let events: [String]
    let topics: [String]
}
