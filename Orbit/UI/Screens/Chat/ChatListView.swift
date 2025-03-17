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
                                systemName: "bubble.left.and.bubble.right.fill"
                            )
                            .font(.system(size: 70))
                            .foregroundColor(
                                ColorPalette.secondaryText(for: colorScheme))
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
                                NavigationLink(
                                    destination: ChatDetailView(chat: chat)
                                ) {
                                    ChatRowView(
                                        chat: chat,
                                        currentUser: userVM.currentUser)
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
        }
        .onAppear {
            Task {
                await chatVM.fetchChats()
            }
        }
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
