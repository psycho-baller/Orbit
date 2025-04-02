//
//  UserProfileView.swift
//  Orbit
//
//  Created by Nathaniel D'Orazio on 2024-12-18.
//

import SwiftUI

struct UserProfileView: View {
    let user: UserModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var chatRequestVM: ChatRequestViewModel
    @EnvironmentObject var userVM: UserViewModel
    @State private var showingMessageSheet = false
    @State private var message = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        ProfilePageView()
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
                    ZStack {
                        ColorPalette.background(for: colorScheme)
                            .ignoresSafeArea()

                        VStack(spacing: 24) {
                            Text("Send a request to \(user.username)")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(
                                    ColorPalette.text(for: colorScheme)
                                )
                                .padding(.top, 24)

                            TextField(
                                "Hi! Would you like to meet up?",
                                text: $message, axis: .vertical
                            )
                            .frame(height: 150, alignment: .top)
                            .padding()
                            .background(ColorPalette.main(for: colorScheme))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        ColorPalette.accent(for: colorScheme),
                                        lineWidth: 1)
                            )
                            .padding(.horizontal)
                            .padding(.top, 24)

                            Button(action: {
                                if let currentUser = userVM.currentUser {
                                    let request = ChatRequestModel(
                                        senderAccountId: currentUser.accountId,
                                        receiverAccountId: user.accountId,
                                        message: message.isEmpty
                                            ? "👋 Hi! Would you like to meet up?"
                                            : message
                                    )
                                    Task {
                                        await chatRequestVM.sendMeetUpRequest(
                                            request: request,
                                            from: currentUser.username
                                        )
                                    }
                                    showingMessageSheet = false
                                }
                            }) {
                                HStack {
                                    Image(systemName: "paperplane.fill")
                                    Text("Send Request")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    ColorPalette.accent(for: colorScheme)
                                )
                                .cornerRadius(16)
                            }
                            .padding(.horizontal)

                            Spacer()
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                showingMessageSheet = false
                            }
                            .foregroundColor(
                                ColorPalette.accent(for: colorScheme))
                        }
                    }
                }
                .presentationDetents([.medium])
                .presentationBackground(.ultraThinMaterial)
            }
    }
}
