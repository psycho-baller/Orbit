//
//  MainTabView.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-10-08.
//  Copyright © 2024 CPSC 575. All rights reserved.
//

//import AnimatedTabBar
import SwiftUI

enum MainViewTabs {
    case home
    case create
    case messages
    case profile
}
struct MainTabView: View {
    @EnvironmentObject var chatRequestVM: ChatRequestViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var appState: AppState

    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            //            NavigationView {
            HomeView()
                //            }
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(MainViewTabs.home)
            
            //            NavigationView {
            CreateMeetupTypeView()
                .tabItem {
                    Label("Create", systemImage: "plus.circle.fill")
                }
                .tag(MainViewTabs.create)
            
            InboxView()
                            //            }
                .tabItem {
                    Label("Messages", systemImage: "message.fill")
                }
                .tag(MainViewTabs.messages)

            //            NavigationView {
            //                if let user = authViewModel.user {
            ProfileView()
                //                } else {
                //                    Text("Please log in to view your profile.")
                //                }
                //            }
                .tabItem {
                    Label("Profile", systemImage: "person.circle.fill")
                }
                .tag(MainViewTabs.profile)
        }
        .accentColor(ColorPalette.accent(for: colorScheme))
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
