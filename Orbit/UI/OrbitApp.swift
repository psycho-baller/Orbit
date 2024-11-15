//
//  OrbitApp.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-10-16.
//

import SwiftUI

@main
struct OrbitApp: App {

    @StateObject var authVM = AuthViewModel()
    @StateObject var userVM = UserViewModel()
    @StateObject var notificationService = NotificationService()
    @StateObject var chatRequestVM = ChatRequestViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                // .attachEnvironmentOverrides()
                .environmentObject(authVM)
                .environmentObject(userVM)
                .environmentObject(notificationService)
                .environmentObject(chatRequestVM)
        }
    }
}
