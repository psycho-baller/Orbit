//
//  MainTabView.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-10-08.
//  Copyright © 2024 CPSC 575. All rights reserved.
//


import SwiftUI
import AnimatedTabBar

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var userViewModel = UserViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    @State private var selectedIndex = 0
    @State private var prevSelectedIndex = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            // Content for each tab based on selectedIndex
            VStack {
                if selectedIndex == 0 {
                    NavigationView {
                        HomeView()
                    }
                } else if selectedIndex == 1 {
                    NavigationView {
                        ExampleView1()
                    }
                } else if selectedIndex == 2 {
                    NavigationView {
                        ExampleView2()
                    }
                } else if selectedIndex == 3 {
                    NavigationView {
                        ExampleView3()
                    }
                } else if selectedIndex == 4 {
                    NavigationView {
                        if let user = authViewModel.user {
                            ProfileView()
                        } else {
                            Text("Please log in to view your profile.")
                        }
                    }
                }
            }
            
            // Animated Tab Bar
            AnimatedTabBar(selectedIndex: $selectedIndex, prevSelectedIndex: $prevSelectedIndex) {
                tabButtonAt(0, icon: "house.fill", title: "Home")
                tabButtonAt(1, icon: "person.2.fill", title: "Tab 2")
                tabButtonAt(2, icon: "star.fill", title: "Tab 3")
                tabButtonAt(3, icon: "gearshape.fill", title: "Tab 4")
                tabButtonAt(4, icon: "person.circle.fill", title: "Profile")
            }
            .cornerRadius(16)
            .selectedColor(ColorPalette.selectedItem(for: colorScheme))
            .unselectedColor(ColorPalette.secondaryText(for: colorScheme))
            .ballColor(ColorPalette.selectedItem(for: colorScheme))
            .verticalPadding(20)
            .ballTrajectory(.straight)
            .ballAnimation(.interpolatingSpring(stiffness: 130, damping: 15))
            .indentAnimation(.easeOut(duration: 0.3))
            .barColor(ColorPalette.accent(for: colorScheme))
        }
        .edgesIgnoringSafeArea(.bottom)
    }

    // Helper function to create tab buttons with icons and titles
    func tabButtonAt(_ index: Int, icon: String, title: String) -> some View {
        VStack {
            Image(systemName: icon)
                .font(.system(size: 24))
            Text(title)
                .font(.caption)
        }
        .scaleEffect(selectedIndex == index ? 1.2 : 1.0) // Add scale effect for selected tab
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
