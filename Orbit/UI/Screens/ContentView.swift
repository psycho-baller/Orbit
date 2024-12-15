//
//  ContentView.swift
//  Orbit
//
//  Created by Alexey Naumov on 23.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

// Main ContentView with Splash Screen and Authentication Logic
import Combine
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var appState: AppState
    @State private var showSplashScreen = true
    @State private var isOneSecondAfterLaunch = false

    var body: some View {
        ZStack {
            if showSplashScreen {
                SplashScreenView(isActive: $showSplashScreen)
            } else {
                if authVM.isLoggedIn {
                    LoggedInView()
                } else if !authVM.isLoggedIn && !authVM.isLoading {
                    LoginView()
                        //                            .navigationDestination(for: String.self) { screen in
                        //                                navigateToView(screen: screen)
                        //                            }
                        .transition(
                            .asymmetric(
                                insertion: isOneSecondAfterLaunch
                                    ? .move(edge: .leading)
                                    : .scale,
                                removal: .move(edge: .leading))
                        )
                }
            }
        }
        .animation(
            .easeInOut, value: authVM.isLoggedIn || authVM.isLoading
        )
        .onAppear {
            Task {
                await authVM.initialize()
                try await Task.sleep(nanoseconds: 1_000_000_000)
                isOneSecondAfterLaunch = true
            }
        }
    }

    @ViewBuilder
    func navigateToView(screen: MainViewTabs) -> some View {
        switch screen {
        case .home:
            HomeView()
        case .messages:
            InboxView()
        case .profile:
            ProfileView()
        //        default:
        //            Text("Unknown Destination")
        }
    }
}

// Splash Screen with Loading Icon
struct SplashScreenView: View {
    @Binding var isActive: Bool  // Use binding to change from splash to content
    @State private var isAnimating = false
    @State private var showT = false
    @State private var showI = false
    @State private var showB = false
    @State private var showR = false
    @Environment(\.colorScheme) var colorScheme  // Detect light/dark mode

    var body: some View {
        ZStack {
            ColorPalette.background(for: colorScheme)  // Background color
                .ignoresSafeArea()  // Make sure it covers the whole screen
            VStack {
                HStack(spacing: 0) {
                    // "O" part of the logo
                    Image("Orbit_O")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(ColorPalette.accent(for: colorScheme))
                        .offset(x: isAnimating ? 30 : 41, y: -3)
                        .scaleEffect(isAnimating ? 3 : 6)
                        .animation(
                            .easeInOut(duration: 1.5).delay(0.4),
                            value: isAnimating)

                    // Remaining letters ("rbit"), revealed one by one
                    Text("r")
                        .font(.custom("Bahnschrift", size: 72))
                        .foregroundColor(ColorPalette.accent(for: colorScheme))
                        .opacity(showR ? 1 : 0)
                        .offset(x: -14)
                        .animation(
                            .easeInOut(duration: 0.3).delay(0.9), value: showR)

                    Text("b")
                        .font(.custom("Bahnschrift", size: 72))
                        .foregroundColor(ColorPalette.accent(for: colorScheme))
                        .opacity(showB ? 1 : 0)
                        .offset(x: -14)
                        .animation(
                            .easeInOut(duration: 0.3).delay(0.8), value: showB)

                    Text("i")
                        .font(.custom("Bahnschrift", size: 72))
                        .foregroundColor(ColorPalette.accent(for: colorScheme))
                        .opacity(showI ? 1 : 0)
                        .offset(x: -14)
                        .animation(
                            .easeInOut(duration: 0.3).delay(0.7), value: showI)

                    Text("t")
                        .font(.custom("Bahnschrift", size: 72))
                        .foregroundColor(ColorPalette.accent(for: colorScheme))
                        .opacity(showT ? 1 : 0)
                        .offset(x: -14)
                        .animation(
                            .easeInOut(duration: 0.3).delay(0.6), value: showT)
                }

                // Loading indicator below the logo
                ProgressView("Loading...")
                    .foregroundColor(ColorPalette.text(for: colorScheme))
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding(.top, 20)
            }
            .onAppear {
                withAnimation {
                    isAnimating = true
                    showT = true
                    showI = true
                    showB = true
                    showR = true
                }

                // Automatically switch to the main screen after the animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        self.isActive = false
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
    #Preview {
        ContentView()
            .environmentObject(AuthViewModel())
            .environmentObject(UserViewModel())
            .environmentObject(AppState())
    }
#endif

//MARK: ORIGINAL CODE

//
//import Combine
//import SwiftUI
//
//// MARK: - View
//
//struct ContentView: View {
//    @EnvironmentObject var authVM: AuthViewModel
//    @EnvironmentObject var userVM: UserViewModel
//
//    @State var isOneSecondAfterLaunch = false
//    //    init(viewModel: ViewModel) {
//    //        self.viewModel = viewModel
//    //        _authVM =
//    //            StateObject(
//    //                wrappedValue: AuthViewModel(
//    //                    viewModel.container.services.accountManagementService
//    //                )
//    //            )
//    //    }
//
//    var body: some View {
//        NavigationView {
//            ZStack {
//                if authVM.isLoading {
//                    // Show a loading indicator while checking login status
//                    ProgressView("Loading...")
//                        .progressViewStyle(CircularProgressViewStyle())
//                        .frame(maxWidth: .infinity, maxHeight: .infinity)
//                        .transition(.opacity.combined(with: .scale))  // Loading transition
//                }
//                if authVM.isLoggedIn {
//                    //                    CountriesList(
//                    //                        viewModel: .init(container: viewModel.container)
//                    //                    )
//                    //                    .attachEnvironmentOverrides(
//                    //                        onChange: viewModel.onChangeHandler
//                    //                    )
//                    //                    .modifier(
//                    //                        RootViewAppearance(
//                    //                            viewModel: .init(container: viewModel.container))
//                    //                    )
//                    //                    .transition(
//                    //                        .move(edge: .trailing)
//                    //                    )
//                    MainTabView()
//
//                }
//                if !authVM.isLoggedIn && !authVM.isLoading {
//
//                    LoginView()
//                        //                            .transition(.move(edge: .leading))  // Regular transition
//                        .transition(
//                            .asymmetric(
//                                insertion: isOneSecondAfterLaunch
//                                    ? .move(edge: .leading) : .scale,
//                                removal: .move(edge: .leading))
//                        )
//
//                }
//            }.animation(
//                .easeInOut, value: authVM.isLoggedIn || authVM.isLoading)
//        }.onAppear {
//            Task {
//                await authVM.initialize()
//                // wait for 1 second
//                try await Task.sleep(nanoseconds: 1 * 1_000_000_000)
//                isOneSecondAfterLaunch = true
//            }
//
//        }
//    }
//
//}
//
//
//// MARK: - Preview
//
//#if DEBUG
//    #Preview{
//        ContentView()
//            .environmentObject(AuthViewModel())
//            .environmentObject(UserViewModel())
//    }
//#endif
