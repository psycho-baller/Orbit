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
    @StateObject var meetupRequestVM = MeetupRequestViewModel()
    @StateObject var chatVM = ChatViewModel()
    @StateObject var navigationCoordinator = AuthNavigationCoordinator()
    @Environment(\.colorScheme) var colorScheme

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundEffect = UIBlurEffect(
            style: .systemUltraThinMaterial)
        appearance.backgroundColor = UIColor.clear

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance

        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        // Set a blur effect (e.g., regular or extraLight)
        navBarAppearance.backgroundEffect = UIBlurEffect(
            style: .systemUltraThinMaterial)
        navBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 24, weight: .bold),
        ]
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance

        // Scroll edge appearance (used when at the top)
        let scrollEdgeAppearance = UINavigationBarAppearance()
        scrollEdgeAppearance.configureWithTransparentBackground()
        scrollEdgeAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 24, weight: .bold),
        ]
        UINavigationBar.appearance().scrollEdgeAppearance = scrollEdgeAppearance
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                // .attachEnvironmentOverrides()
                .environmentObject(authVM)
                .environmentObject(userVM)
                .environmentObject(msgVM)
                .environmentObject(chatRequestVM)
                .environmentObject(meetupRequestVM)
                .environmentObject(chatVM)
                .environmentObject(appDelegate.appState)
                .environmentObject(navigationCoordinator)
                .accentColor(ColorPalette.accent(for: colorScheme))
        }
    }
}
