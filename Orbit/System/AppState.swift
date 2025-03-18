//
//  AppState.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-11-23.
//

import Combine
import Foundation
import SwiftUI

class AppState: ObservableObject {
    @Published var selectedTab: MainViewTabs = .home
    @Published var messagesNavigationPath: [ChatDocument] = []
    @Published var targetScreen: String? = nil  // Tracks the target screen for deep links
    @Published var selectedRequestId: String? = nil
    @Published var isShowingHomeSettings = false

}
