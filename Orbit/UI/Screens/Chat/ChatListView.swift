//
//  ChatListView.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-03-14.
//

import SwiftUI

struct ChatListView: View {
    @EnvironmentObject var chatVM: ChatViewModel
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        // Check if user exists
        if let currentUser = userVM.currentUser {
            NavigationStack(path: $appState.messagesNavigationPath) {
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            ColorPalette.background(for: colorScheme),
                            ColorPalette.main(for: colorScheme),
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()

                    VStack {
                        if chatVM.chats.isEmpty {
                            VStack(spacing: 16) {
                                Image(
                                    systemName:
                                        "bubble.left.and.bubble.right.fill"
                                )
                                .font(.system(size: 70))
                                .foregroundColor(
                                    ColorPalette.secondaryText(for: colorScheme)
                                )
                                Text("No Chats Yet")
                                    .font(.title)
                                    .foregroundColor(
                                        ColorPalette.text(for: colorScheme))
                                Text(
                                    "Your chats will appear here when you start a conversation."
                                )
                                .font(.body)
                                .foregroundColor(
                                    ColorPalette.secondaryText(for: colorScheme)
                                )
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            }
                            .frame(maxHeight: .infinity)
                        } else {
                            List {
                                ForEach(chatVM.chats, id: \.id) { chat in
                                    Button {
                                        appState.messagesNavigationPath.append(
                                            chat)
                                    } label: {
                                        ChatRowView(
                                            chat: chat,
                                            currentUser: userVM.currentUser
                                        )
                                    }
                                }
                            }
                            .scrollContentBackground(.hidden)
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Text("Chats")
                                .largeBoldFont()
                                .foregroundColor(
                                    ColorPalette.text(for: colorScheme))
                        }
                    }
                }
                .navigationDestination(for: ChatDocument.self) { chat in
                    ChatDetailView(
                        chat: chat,
                        user: currentUser
                    )
                }
            }
            .onAppear {
                Task {
                    await chatVM.fetchChats()
                }
            }
        } else {
            // If no user is available, show an error screen.
            ErrorScreen()
        }
        .padding()
        .background(Color.white.opacity(0.05)) // ✅ Light overlay for message bubble
        .cornerRadius(12)
    }

 
    func formatTime(_ timestamp: String) -> String {
        guard let date = DateFormatterUtility.parseISO8601(timestamp) else { return "" }
        return DateFormatterUtility.dateOnlyFormatter.string(from: date)
    }

   
    func sendAutoResponse(_ chat: ChatDocument) {
        print("Auto-response sent to \(chat.id)")
        // Implement actual message sending logic here
    }
}

struct ChatListRow: View {
    let chat: ChatDocument

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                // Profile Image
                Image("profile_pic") // Replace with actual image logic
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 1))

                // Chat Info
                VStack(alignment: .leading, spacing: 4) {
                    Text( "No messages yet")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                }

                Spacer()
            }
            
        
            Button(action: {
                sendAutoResponse(chat)
            }) {
                HStack {
                    Image(systemName: "cup.and.saucer.fill")
                        .foregroundColor(.white)
                    
                    Text("What's your favorite food place in MacHall?")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right") // ✅ Arrow icon for interaction
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.cyan.opacity(0.9)) // ✅ Cyan background
                .cornerRadius(12)
            }
        }
    }
}



#if DEBUG
    #Preview {
        ChatListView()
            .environmentObject(ChatViewModel.mock())
            .environmentObject(UserViewModel.mock())
            .environmentObject(AppState())
            .accentColor(ColorPalette.accent(for: .light))
    }
#endif
