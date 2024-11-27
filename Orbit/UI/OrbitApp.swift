//
//  OrbitApp.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-10-16.
//

import SwiftUI

@main
struct OrbitApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject var authVM = AuthViewModel()
    @StateObject var userVM = UserViewModel()
    @StateObject var msgVM = MessagingViewModel()
    @StateObject var chatRequestVM = ChatRequestViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                // .attachEnvironmentOverrides()
                .environmentObject(authVM)
                .environmentObject(userVM)
                .environmentObject(msgVM)
                .environmentObject(chatRequestVM)
<<<<<<< HEAD
=======
                .environmentObject(appDelegate.appState)
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
        }
    }
}
