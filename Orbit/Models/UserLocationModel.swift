//
//  UserLocation.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-10-29.
//


struct UserLocation: Codable, Identifiable {
    let id: String                 // Unique user reference
    let timestamp: Date            // Time of the location update
    let latitude: Double           // User’s latitude in high-accuracy mode
    let longitude: Double          // User’s longitude in high-accuracy mode
}