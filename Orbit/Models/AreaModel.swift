//
//  AreaModel.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-10-28.
//

struct Area: Codable {
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
}
