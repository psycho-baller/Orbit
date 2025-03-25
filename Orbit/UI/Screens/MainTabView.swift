//
//  MainTabView.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-10-08.
//  Copyright © 2024 CPSC 575. All rights reserved.
//
import SwiftUI

enum MainViewTabs {
    case home
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

    @State private var showCreateSheet = false

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $appState.selectedTab) {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(MainViewTabs.home)

                MyOrbitScreen()
                    .tabItem {
                        Label("My Orbit", systemImage: "circle.circle.fill")
                    }
                    .tag(MainViewTabs.myOrbit)

                // Empty tab for center button
                Button {
                    showCreateSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 36, weight: .light))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(ColorPalette.accent(for: colorScheme))
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                //Color.clear
                //    .tabItem { Label("", systemImage: "") }

                ChatListView()
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
            .background(Color.darkIndigo.ignoresSafeArea())
            .accentColor(.cyan)
            .onAppear {
                UITabBar.appearance().barTintColor = UIColor(Color.darkIndigo.opacity(0.8))
                UITabBar.appearance().isTranslucent = true
            }

            // Custom center button
            
            Button {
                showCreateSheet = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 36, weight: .light))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.cyan)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
        }
        .sheet(isPresented: $showCreateSheet) {
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
            .environmentObject(ChatViewModel.mock())
    }
#endif
