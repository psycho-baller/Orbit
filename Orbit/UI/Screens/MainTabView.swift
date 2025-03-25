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
        ZStack {
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
                Color.clear
                    .tabItem { 
                        Label(" ", systemImage: "plus.circle.fill")
                            .opacity(0)
                    }


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
            .accentColor(ColorPalette.accent(for: colorScheme))

            // Custom "Create" button in a fixed positon
            VStack {
                Spacer()
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
                .buttonStyle(CreateButtonStyle())
                .offset(y: 0) // Adjust this value to position above tab bar
            }
            .ignoresSafeArea(.keyboard)
        }
        .sheet(isPresented: $showCreateSheet) {
            CreateMeetupTypeView()
        }
    }
}

// Button Press Animation
struct CreateButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
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
