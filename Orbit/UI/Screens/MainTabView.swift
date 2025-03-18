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
    case myOrbit
}
struct MainTabView: View {
    @EnvironmentObject var chatRequestVM: ChatRequestViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var appState: AppState

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $appState.selectedTab) {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(MainViewTabs.home)
                
                MyOrbitView()
                    .tabItem {
                        Label("My Plans", systemImage: "circle.circle.fill")
                    }
                    .tag(MainViewTabs.myOrbit)
                
                
                // Empty tab for center button
                Color.clear
                    .tabItem { Label("", systemImage: "") }
                    .tag(MainViewTabs.create)
                    
                MyMessages()
                    .tabItem {
                        Label("Messages", systemImage: "message.fill")
                    }
                    .tag(MainViewTabs.messages)
                
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.circle.fill")
                    }
                    .tag(MainViewTabs.profile)
            }
            .accentColor(ColorPalette.accent(for: colorScheme))
            
            // Custom center button
            Button {
                appState.selectedTab = .create
            } label: {
                
                Image(systemName: "plus")
                    .font(.system(size: 36, weight: .light))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(ColorPalette.accent(for: colorScheme))
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }


            
        }
        .sheet(isPresented: .init(
            get: { appState.selectedTab == .create },
            set: { if !$0 { appState.selectedTab = .home } }
        )) {
            CreateMeetupTypeView()
        }
    }
}

#if DEBUG
    #Preview {
        MainTabView()
            .environmentObject(AppState())
            .environmentObject(UserViewModel.mock())
            .environmentObject(AuthViewModel.mock())
            .environmentObject(ChatRequestViewModel.mock())
            .environmentObject(MeetupRequestViewModel.mock())

    }
#endif
