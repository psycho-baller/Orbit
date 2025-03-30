//
//  ProfileView.swift
//  Orbit
//
//  Created by Nathaniel D'Orazio on 2024-10-19.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showingBottomSheet = false
    @State private var selectedInterests: [String] = []
    @State private var orbitAngle: Double = 0
    
    var body: some View {
        if let currentUser = userViewModel.currentUser {
            ProfilePageView(user: currentUser, isCurrentUserProfile: true) //Only place where this is true
        } else {
            ProgressView()
        }
    }
}

// MARK: - Preview
#if DEBUG
    #Preview {
        ProfileView()
            .environmentObject(AuthViewModel())
            .environmentObject(UserViewModel.mock())
    }
#endif
