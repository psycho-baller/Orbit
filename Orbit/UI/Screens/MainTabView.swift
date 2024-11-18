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
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @Environment(\.colorScheme) var colorScheme

    @State private var selectedIndex = 0
    @State private var prevSelectedIndex = 0

    var body: some View {
        TabView {
            NavigationView {
                HomeView()
                    .navigationTitle("Home")
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }

            NavigationView {
                InboxView()
            }
            .tabItem {
                Label("Messages", systemImage: "message.fill")
            }

            NavigationView {
                ExampleView2()
                    .navigationTitle("Tab 3")
            }
            .tabItem {
                Label("Tab 3", systemImage: "star.fill")
            }

            NavigationView {
                ExampleView3()
                    .navigationTitle("Tab 4")
            }
            .tabItem {
                Label("Tab 4", systemImage: "gearshape.fill")
            }

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
        }
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

// Preview for MainTabView
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(UserViewModel())
            .environmentObject(AuthViewModel())
    }
}
