//
//  UserLocationModel.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-10-29.
//

struct UserLocationModel: Codable, Identifiable {
    let id: String  // Unique user reference
    let latitude: Double  // User’s latitude in high-accuracy mode
    let longitude: Double  // User’s longitude in high-accuracy mode
}
