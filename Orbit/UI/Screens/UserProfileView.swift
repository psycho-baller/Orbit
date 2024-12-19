//
//  UserProfileView.swift
//  Orbit
//
//  Created by Nathaniel D'Orazio on 2024-12-18.
//

import SwiftUI

struct UserProfileView: View {
    let user: UserModel
    let currentUser: UserModel?
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var chatRequestVM: ChatRequestViewModel
    @EnvironmentObject var userVM: UserViewModel
    @State private var orbitAngle: Double = 0
    @State private var showingMessageSheet = false
    @State private var message = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Header
                ZStack {
                    // Background gradient
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    ColorPalette.accent(for: colorScheme).opacity(0.2),
                                    ColorPalette.background(for: colorScheme)
                                ]),
                                center: .center,
                                startRadius: 5,
                                endRadius: 150
                            )
                        )
                        .frame(maxWidth: .infinity)
                        .scaleEffect(1.5)
                        .padding()
                    
                    // Profile Image
                    if let profileUrl = user.profilePictureUrl,
                       let url = URL(string: profileUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(ColorPalette.accent(for: colorScheme), lineWidth: 2))
                        } placeholder: {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(ColorPalette.accent(for: colorScheme), lineWidth: 2))
                        }
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(ColorPalette.accent(for: colorScheme), lineWidth: 2))
                    }
                    
                    // Orbiting Interests
                    if let interests = user.interests {
                        ForEach(Array(interests.enumerated()), id: \.element) { index, interest in
                            InterestOrbit(
                                interest: interest,
                                index: index,
                                totalCount: interests.count,
                                orbitAngle: orbitAngle
                            )
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .onAppear {
                    withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                        orbitAngle = 45
                    }
                }
                
                // User Info
                VStack(alignment: .leading, spacing: 16) {
                    Text(user.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    // Social Style Section
                    if let socialStyle = user.socialStyle {
                        PreferenceSection(title: "Social Style", items: socialStyle)
                    }
                    
                    // Interaction Preferences
                    if let preferences = user.interactionPreferences {
                        PreferenceSection(title: "How I Like to Connect", items: preferences)
                    }
                    
                    // Friendship Values
                    if let values = user.friendshipValues {
                        PreferenceSection(title: "What I Value in Friendships", items: values)
                    }
                    
                    // Social Situations
                    if let situations = user.socialSituations {
                        PreferenceSection(title: "Social Situations I Enjoy", items: situations)
                    }
                    
                    // Lifestyle Preferences
                    if let lifestyle = user.lifestylePreferences {
                        PreferenceSection(title: "Lifestyle", items: lifestyle)
                    }
                }
                .padding()
                .background(ColorPalette.main(for: colorScheme))
                .cornerRadius(20)
                .padding(.horizontal)
            }
        }
        .background(ColorPalette.background(for: colorScheme))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingMessageSheet = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "hand.wave.fill")
                        Text("Request")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(ColorPalette.accent(for: colorScheme))
                    .cornerRadius(20)
                }
            }
        }
        .sheet(isPresented: $showingMessageSheet) {
            NavigationStack {
                VStack(spacing: 16) {
                    Text("Send a request to \(user.name)")
                        .font(.headline)
                        .padding(.top)
                    
                    TextField("Hi! Would you like to meet up?", text: $message, axis: .vertical)
                        .padding()
                        .background(ColorPalette.main(for: colorScheme))
                        .cornerRadius(20)
                        .padding(.horizontal)
                        .focused($isTextFieldFocused)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                isTextFieldFocused = true
                            }
                        }
                    
                    Spacer()
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            showingMessageSheet = false
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Send") {
                            guard let currentUser = currentUser else {
                                print("Error: Current user is nil.")
                                return
                            }
                            
                            let request = ChatRequestModel(
                                senderAccountId: currentUser.accountId,
                                receiverAccountId: user.accountId,
                                message: message.isEmpty ? "👋 Hi! Would you like to meet up?" : message
                            )
                            
                            Task {
                                await chatRequestVM.sendMeetUpRequest(
                                    request: request,
                                    from: currentUser.name
                                )
                                await chatRequestVM.fetchRequestsForUser(userId: currentUser.accountId)
                                showingMessageSheet = false
                                dismiss()
                            }
                        }
                    }
                }
                .background(ColorPalette.background(for: colorScheme))
            }
            .presentationBackground(ColorPalette.background(for: colorScheme))
        }
    }
}

struct ProfileSection<Content: View>: View {
    let title: String
    let content: Content
    @Environment(\.colorScheme) var colorScheme
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(ColorPalette.accent(for: colorScheme))
            
            content
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ColorPalette.main(for: colorScheme))
        .cornerRadius(16)
    }
}

