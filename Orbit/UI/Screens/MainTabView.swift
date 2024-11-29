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

    //@State private var selectedTab = 0

    @State private var selectedIndex = 0
    @State private var prevSelectedIndex = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                if selectedIndex == 0 {
                    NavigationView {
                        HomeView()
                    }
                } else if selectedIndex == 1 {
                    NavigationView {
                        InboxView()
                    }
                } else if selectedIndex == 2 {
                    NavigationView {
                        ProfileView()
                    }
                }
            }

            // Animated Tab Bar
            AnimatedTabBar(
                selectedIndex: $selectedIndex,
                prevSelectedIndex: $prevSelectedIndex
            ) {
                tabButtonAt(0, icon: "house.fill", title: "Home")
                tabButtonAt(1, icon: "message.fill", title: "Messages")
                tabButtonAt(2, icon: "person.fill", title: "Profile")
            }
            .cornerRadius(16)
            .selectedColor(ColorPalette.text(for: colorScheme))
            .unselectedColor(ColorPalette.secondaryText(for: colorScheme))
            .ballColor(ColorPalette.text(for: colorScheme))
            .verticalPadding(20)
//            .ballTrajectory(.straight)
//            .ballAnimation(.interpolatingSpring(stiffness: 130, damping: 15))
//            .indentAnimation(.easeOut(duration: 0.3))
            .barColor(ColorPalette.background(for: colorScheme))
        }
        .accentColor(ColorPalette.accent(for: colorScheme))
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
        .scaleEffect(selectedIndex == index ? 1.15 : 1.0)  // Add scale effect for selected tab
    }
}

#if DEBUG
    #Preview {

        MainTabView()
            .environmentObject(AppState())
            .environmentObject(UserViewModel.mock())
            .environmentObject(AuthViewModel.mock())
            .environmentObject(ChatRequestViewModel.mock())
            .environmentObject(MessagingViewModel())

    }
#endif
