//
//  NavigationStore.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-12-15.
//


import Foundation
import SwiftUI

class NavigationStore: ObservableObject {
    @Published var path: NavigationPath
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    init(initialPath: NavigationPath = NavigationPath()) {
        self.path = initialPath
    }
    
    func append(_ value: some Hashable) {
        path.append(value)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func encoded() -> Data? {
        try? path.codable.map(encoder.encode)
    }
    
    func restore(from data: Data) {
        do {
            let codable = try decoder.decode(NavigationPath.CodableRepresentation.self, from: data)
            path = NavigationPath(codable)
        } catch {
            print("Error restoring navigation path: \(error.localizedDescription)")
        }
    }
}
