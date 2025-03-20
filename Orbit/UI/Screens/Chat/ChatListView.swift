//
//  ChatListView.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-03-14.
//

import SwiftUI

import SwiftUI

struct ChatListView: View {
    @EnvironmentObject var chatVM: ChatViewModel
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(chatVM.chats) { chat in
                        NavigationLink(destination: ChatDetailView(chat: chat)) {
                            ChatListRow(chat: chat)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .background(Color.darkIndigo.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline) // Make space for custom title
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("My Messages")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.cyan) // ✅ Cyan title
                }
            }
        }
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



#if DEBUG
    #Preview {
        @Previewable @Environment(\.colorScheme) var colorScheme

        ChatListView()
            .environmentObject(ChatViewModel.mock())
            .environmentObject(UserViewModel.mock())
            .environmentObject(AppState())
            .accentColor(ColorPalette.accent(for: colorScheme))
    }
#endif
