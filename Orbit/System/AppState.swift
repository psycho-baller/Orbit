//
//  AppState.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-11-23.
//

import Foundation
import SwiftUI

class AppState: ObservableObject {
    @Published var navigationPath = NavigationPath()  // Manages the navigation stack
    @Published var targetScreen: String? = nil  // Tracks the target screen for deep links
    @Published var selectedRequestId: String? = nil  // Add this line

}
