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

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundEffect = UIBlurEffect(
            style: .systemUltraThinMaterial)  // Material background
        appearance.backgroundColor = UIColor.clear  // You can adjust this if needed

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                // .attachEnvironmentOverrides()
                .environmentObject(authVM)
                .environmentObject(userVM)
                .environmentObject(msgVM)
                .environmentObject(chatRequestVM)
                .environmentObject(appDelegate.appState)
        }
    }
}
