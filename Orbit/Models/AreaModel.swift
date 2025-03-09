//
//  AreaModel.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-10-28.
//
import Foundation

struct Area: Codable, Identifiable {
    let id: String
    let name: String
    let lon: Double
    let lat: Double
    let categories: [String]

    enum CodingKeys: String, CodingKey {
        case id, name, lon, lat, categories
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        lon = try container.decode(Double.self, forKey: .lon)
        lat = try container.decode(Double.self, forKey: .lat)
        categories = try container.decode([String].self, forKey: .categories)

        // Custom decoding for id
        if let idInt = try? container.decode(Int.self, forKey: .id) {
            id = String(idInt)
        } else {
            id = try container.decode(String.self, forKey: .id)
        }
    }

    // Helper function to calculate the distance between two coordinates using the Haversine formula
    func distance(from: Area) -> Double {
        let earthRadius = 6371.0  // Radius of Earth in kilometers

        let lat1 = self.lat.degreesToRadians
        let lon1 = self.lon.degreesToRadians
        let lat2 = from.lat.degreesToRadians
        let lon2 = from.lon.degreesToRadians

        let dLat = lat2 - lat1
        let dLon = lon2 - lon1

        let a =
            sin(dLat / 2) * sin(dLat / 2) + cos(lat1) * cos(lat2)
            * sin(dLon / 2) * sin(dLon / 2)

        let c = 2 * atan2(sqrt(a), sqrt(1 - a))

        return earthRadius * c  // Distance in kilometers
    }
}
