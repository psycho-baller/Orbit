//
//  ContentView.swift
//  Orbit
//
//  Created by Alexey Naumov on 23.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

<<<<<<< HEAD
import Combine
import SwiftUI

// Main ContentView with Splash Screen and Authentication Logic
struct ContentView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var userVM: UserViewModel
    @State var isOneSecondAfterLaunch = false
    @State private var showSplashScreen = true
    @Environment(\.colorScheme) var colorScheme  // Detect light/dark mode
=======
// Main ContentView with Splash Screen and Authentication Logic
import Combine
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var appState: AppState
    @State private var showSplashScreen = true
    @State private var isOneSecondAfterLaunch = false
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac

    var body: some View {
        ZStack {
            if showSplashScreen {
                SplashScreenView(isActive: $showSplashScreen)
            } else {
<<<<<<< HEAD
                NavigationView {
                    ZStack {
                        if authVM.isLoggedIn {
                            MainTabView()
                        }
                        if !authVM.isLoggedIn && !authVM.isLoading {
                            LoginView()
                                .transition(
                                    .asymmetric(
                                        insertion: isOneSecondAfterLaunch
                                            ? .move(edge: .leading)
                                            : .scale,
                                        removal: .move(edge: .leading))
                                )
                        }
                    }
                    .animation(.easeInOut, value: authVM.isLoggedIn || authVM.isLoading)
                }
                .onAppear {
                    Task {
                        await authVM.initialize()
                        // Wait for 1 second after splash
                        try await Task.sleep(nanoseconds: 1 * 1_000_000_000)
=======
                NavigationStack(path: $appState.navigationPath) {
                    if authVM.isLoggedIn {
                        MainTabView()
                            .navigationDestination(for: String.self) { screen in
                                navigateToView(screen: screen)
                            }
                    } else if !authVM.isLoggedIn && !authVM.isLoading {
                        LoginView()
                            .navigationDestination(for: String.self) { screen in
                                navigateToView(screen: screen)
                            }
                            .transition(
                                .asymmetric(
                                    insertion: isOneSecondAfterLaunch
                                        ? .move(edge: .leading)
                                        : .scale,
                                    removal: .move(edge: .leading))
                            )
                    }
                }
                .animation(
                    .easeInOut, value: authVM.isLoggedIn || authVM.isLoading
                )
                .onAppear {
                    Task {
                        await authVM.initialize()
                        try await Task.sleep(nanoseconds: 1_000_000_000)
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
                        isOneSecondAfterLaunch = true
                    }
                }
            }
        }
    }
<<<<<<< HEAD
}


// Splash Screen with Loading Icon
struct SplashScreenView: View {
    @Binding var isActive: Bool // Use binding to change from splash to content
=======

    @ViewBuilder
    func navigateToView(screen: String) -> some View {
        switch screen {
        case "ProfileScreen":
            ProfileView()
        default:
            Text("Unknown Destination")
        }
    }
}

// Splash Screen with Loading Icon
struct SplashScreenView: View {
    @Binding var isActive: Bool  // Use binding to change from splash to content
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
    @State private var isAnimating = false
    @State private var showT = false
    @State private var showI = false
    @State private var showB = false
    @State private var showR = false
    @Environment(\.colorScheme) var colorScheme  // Detect light/dark mode
<<<<<<< HEAD
    
    var body: some View {
        ZStack {
            ColorPalette.background(for: colorScheme) // Background color
=======

    var body: some View {
        ZStack {
            ColorPalette.background(for: colorScheme)  // Background color
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
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
<<<<<<< HEAD
                        .animation(.easeInOut(duration: 1.5).delay(0.4), value: isAnimating)
                   
=======
                        .animation(
                            .easeInOut(duration: 1.5).delay(0.4),
                            value: isAnimating)

>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
                    // Remaining letters ("rbit"), revealed one by one
                    Text("r")
                        .font(.custom("Bahnschrift", size: 72))
                        .foregroundColor(ColorPalette.accent(for: colorScheme))
                        .opacity(showR ? 1 : 0)
                        .offset(x: -14)
<<<<<<< HEAD
                        .animation(.easeInOut(duration: 0.3).delay(0.9), value: showR)
                    
=======
                        .animation(
                            .easeInOut(duration: 0.3).delay(0.9), value: showR)

>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
                    Text("b")
                        .font(.custom("Bahnschrift", size: 72))
                        .foregroundColor(ColorPalette.accent(for: colorScheme))
                        .opacity(showB ? 1 : 0)
                        .offset(x: -14)
<<<<<<< HEAD
                        .animation(.easeInOut(duration: 0.3).delay(0.8), value: showB)
                    
=======
                        .animation(
                            .easeInOut(duration: 0.3).delay(0.8), value: showB)

>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
                    Text("i")
                        .font(.custom("Bahnschrift", size: 72))
                        .foregroundColor(ColorPalette.accent(for: colorScheme))
                        .opacity(showI ? 1 : 0)
                        .offset(x: -14)
<<<<<<< HEAD
                        .animation(.easeInOut(duration: 0.3).delay(0.7), value: showI)
                    
=======
                        .animation(
                            .easeInOut(duration: 0.3).delay(0.7), value: showI)

>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
                    Text("t")
                        .font(.custom("Bahnschrift", size: 72))
                        .foregroundColor(ColorPalette.accent(for: colorScheme))
                        .opacity(showT ? 1 : 0)
                        .offset(x: -14)
<<<<<<< HEAD
                        .animation(.easeInOut(duration: 0.3).delay(0.6), value: showT)
                }
                
=======
                        .animation(
                            .easeInOut(duration: 0.3).delay(0.6), value: showT)
                }

>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
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
<<<<<<< HEAD
                
=======

>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
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
<<<<<<< HEAD
    #Preview{
        ContentView()
            .environmentObject(AuthViewModel())
            .environmentObject(UserViewModel())
    }
#endif


=======
    #Preview {
        ContentView()
            .environmentObject(AuthViewModel())
            .environmentObject(UserViewModel())
            .environmentObject(AppState())
    }
#endif

>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
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
