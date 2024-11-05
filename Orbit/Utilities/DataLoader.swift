//
//  DataLoader.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-10-28.
//

import Foundation

struct DataLoader {
    static func loadUofCLocationDataFromJSON() -> [Area] {
        guard
            let url = Bundle.main.url(
                forResource: "CleanedUofCLocationData", withExtension: "json")
        else {
            print("CleanedUofCLocationData.json file not found.")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let areas = try decoder.decode([Area].self, from: data)
            return areas
        } catch {
            print(
                "Error loading CleanedUofCLocationData.json: \(error.localizedDescription)"
            )
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .dataCorrupted(let context):
                    print("Data corrupted: \(context)")
                case .keyNotFound(let key, let context):
                    print("Key '\(key)' not found: \(context.debugDescription)")
                case .typeMismatch(let type, let context):
                    print(
                        "Type mismatch for type \(type): \(context.debugDescription)"
                    )
                case .valueNotFound(let type, let context):
                    print(
                        "Value of type \(type) not found: \(context.debugDescription)"
                    )
                @unknown default:
                    print("Unknown decoding error")
                }
            }
            return []
        }
    }
}
