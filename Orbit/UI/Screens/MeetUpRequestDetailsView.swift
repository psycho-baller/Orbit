//
//  MeetUpRequestDetailsView.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-11-15.
//

import SwiftUI

struct MeetUpRequestDetailsView: View {
    @EnvironmentObject var chatRequestVM: ChatRequestViewModel
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var showChat = false
    var request: ChatRequestDocument
    var body: some View {
        NavigationStack {
            VStack {
                HStack(alignment: .top, spacing: 0) {
                    // Profile Picture
                    if let user = userVM.users.first(where: {
                        $0.accountId == request.data.senderAccountId
                    }),
                        let profileUrl = user.profilePictureUrl,
                        let url = URL(string: profileUrl)
                    {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(
                                    Circle().stroke(
                                        ColorPalette.accent(for: colorScheme),
                                        lineWidth: 2))
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                                .foregroundColor(
                                    ColorPalette.secondaryText(for: colorScheme)
                                )
                        }
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .foregroundColor(
                                ColorPalette.secondaryText(for: colorScheme))
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        Text(
                            "Meet-up request from \(userVM.getUserName(from: request.data.senderAccountId))"
                        )
                        .font(.headline)

                        Text(request.data.message)

                        HStack {
                            Button("Approve") {
                                Task {
                                    await chatRequestVM.respondToMeetUpRequest(
                                        requestId: request.id,
                                        response: .approved
                                    )
                                }
                            }
                            .buttonStyle(.borderedProminent)

                            Button("Decline") {
                                Task {
                                    await chatRequestVM.respondToMeetUpRequest(
                                        requestId: request.id,
                                        response: .declined
                                    )
                                    dismiss()
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
                .padding()
            }
            .onChange(of: chatRequestVM.newConversationId) { _, newValue in
                if newValue != nil {
                    showChat = true
                    dismiss()
                }
            }
            .sheet(isPresented: $showChat) {
                if let conversationId = chatRequestVM.newConversationId {
                    NavigationStack {
                        MessageView(
                            conversationId: conversationId,
                            messagerName: userVM.getUserName(
                                from: request.data.senderAccountId)
                        )
                    }
                }
            }
        }
    }
}

#if DEBUG
    #Preview {
        MeetUpRequestDetailsView(
            request: (mockChatRequestDocument as? ChatRequestDocument)!
        )
        .environmentObject(ChatRequestViewModel.mock())
        .environmentObject(UserViewModel.mock())
    }
#endif
