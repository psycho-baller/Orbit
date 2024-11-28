//
//  MainTabView.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-10-08.
//  Copyright © 2024 CPSC 575. All rights reserved.
//

import AnimatedTabBar
import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var chatRequestVM: ChatRequestViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @Environment(\.colorScheme) var colorScheme

    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)

            NavigationView {
                InboxView()
            }
            .tabItem {
                Label("Messages", systemImage: "message.fill")
            }
            .tag(1)

            NavigationView {
                if let user = authViewModel.user {
                    ProfileView()
                } else {
                    Text("Please log in to view your profile.")
                }
            }
            .tabItem {
                Label("Profile", systemImage: "person.circle.fill")
            }
            .tag(2)
        }
        .accentColor(ColorPalette.accent(for: colorScheme))
    }
}

// Example views for other tabs
struct ExampleView1: View {
    var body: some View {
        Text("Content for Tab 2")
            .navigationTitle("Tab 2")
    }
}

struct ExampleView2: View {
    var body: some View {
        Text("Content for Tab 3")
            .navigationTitle("Tab 3")
    }
}

struct ExampleView3: View {
    var body: some View {
        Text("Content for Tab 4")
            .navigationTitle("Tab 4")
    }
}

#if DEBUG
    #Preview {

        MainTabView()
            .environmentObject(AppState())
            .environmentObject(UserViewModel.mock())
            .environmentObject(AuthViewModel.mock())
            .environmentObject(ChatRequestViewModel.mock())

    }
#endif
