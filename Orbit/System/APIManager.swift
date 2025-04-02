//
//  APIManager.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-03-20.
//

import Foundation

class APIManager {
    static let shared = APIManager()
    var APPWRITE_PROJECT_ID: String?

    private init() {
        if let url = Bundle.main.url(
            forResource: "APIKeys", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let plist = try? PropertyListSerialization.propertyList(
                from: data, options: [], format: nil) as? [String: Any]
        {
            APPWRITE_PROJECT_ID =
                plist["APPWRITE_PROJECT_ID"] as? String?
                ?? "67017126001e334dd053"
        }
    }
}
