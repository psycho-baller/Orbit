//
//  ContentView.swift
//  Orbit
//
//  Created by Alexey Naumov on 23.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import Combine
import SwiftUI

// Main ContentView with Splash Screen and Authentication Logic
struct ContentView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var userVM: UserViewModel
    @State var isOneSecondAfterLaunch = false
    @State private var showSplashScreen = true

    var body: some View {
        ZStack {
            if showSplashScreen {
                SplashScreenView(isActive: $showSplashScreen)
            } else {
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
                        isOneSecondAfterLaunch = true
                    }
                }
            }
        }
    }
}


// Splash Screen with Loading Icon
struct SplashScreenView: View {
    @Binding var isActive: Bool // Use binding to change from splash to content
    @State private var isAnimating = false
    @State private var showT = false
    @State private var showI = false
    @State private var showB = false
    @State private var showR = false
    
    var body: some View {
        ZStack {
            VStack {
                HStack(spacing: 0) {
                    // "O" part of the logo
                    Text("O")
                        .font(.system(size: 72, weight: .bold))
                        .foregroundColor(.blue)
                        .offset(x: isAnimating ? 0 : 20)
                        .scaleEffect(isAnimating ? 1 : 3)
                        .animation(.easeInOut(duration: 1.0), value: isAnimating)
                    
                    // Remaining letters ("rbit"), revealed one by one
                    Text("r")
                        .font(.system(size: 72, weight: .bold))
                        .foregroundColor(.blue)
                        .opacity(showR ? 1 : 0)
                        .animation(.easeInOut(duration: 0.3).delay(0.5), value: showR)
                    
                    Text("b")
                        .font(.system(size: 72, weight: .bold))
                        .foregroundColor(.blue)
                        .opacity(showB ? 1 : 0)
                        .animation(.easeInOut(duration: 0.3).delay(0.4), value: showB)
                    
                    Text("i")
                        .font(.system(size: 72, weight: .bold))
                        .foregroundColor(.blue)
                        .opacity(showI ? 1 : 0)
                        .animation(.easeInOut(duration: 0.3).delay(0.3), value: showI)
                    
                    Text("t")
                        .font(.system(size: 72, weight: .bold))
                        .foregroundColor(.blue)
                        .opacity(showT ? 1 : 0)
                        .animation(.easeInOut(duration: 0.3).delay(0.2), value: showT)
                }
                
                // Loading indicator below the logo
                ProgressView("Loading...")
                    .foregroundColor(Color(UIColor.label))
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
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
    #Preview{
        ContentView()
            .environmentObject(AuthViewModel())
            .environmentObject(UserViewModel())
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
