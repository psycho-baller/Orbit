//
//  MeetUpRequestsListView.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-11-15.
//

import SwiftUI

struct MeetUpRequestsListView: View {
    @EnvironmentObject var chatRequestVM: ChatRequestViewModel
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.colorScheme) var colorScheme
    @Binding var chatRequestListDetent: PresentationDetent
    @Environment(\.dismiss) var dismiss
    @State private var navigateToChat = false

    var body: some View {
        NavigationStack {
            //            ZStack {
            VStack(spacing: 0) {
                if let error = chatRequestVM.errorMessage {
                    VStack {
                        Text("Error")
                            .font(.headline)
                            .foregroundColor(.red)
                        Text(error)
                            .multilineTextAlignment(.center)
                            .padding()

                        Button("Retry") {
                            if let accountId = userVM.currentUser?.accountId {
                                Task {
                                    await chatRequestVM.fetchRequestsForUser(
                                        userId: accountId)
                                }
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(ColorPalette.accent(for: colorScheme))
                        .padding()
                    }
                } else if chatRequestVM.requests.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "tray")
                            .font(.system(size: 70))
                            .foregroundColor(
                                ColorPalette.secondaryText(for: colorScheme)
                            )

                        Text("No pending requests")
                            .font(.title)
                            .foregroundColor(
                                ColorPalette.secondaryText(for: colorScheme)
                            )
                            .fontWeight(.semibold)

                        Text(
                            "When someone sends you a meetup request, it will appear here"
                        )
                        .font(.headline)
                        .foregroundColor(
                            ColorPalette.secondaryText(for: colorScheme)
                        )
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 50)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(chatRequestVM.requests) { request in
                                SwipeView {
                                    MeetUpRequestRow(request: request)
                                        .onTapGesture {
                                            chatRequestVM.selectedRequest =
                                                request
                                            chatRequestListDetent = .large
                                        }
                                } leadingActions: { context in
                                    SwipeAction {
                                        Task {
                                            await chatRequestVM
                                                .respondToMeetUpRequest(
                                                    requestId: request.id,
                                                    response: .approved
                                                )
                                        }
                                    } label: { isHighlighted in
                                        VStack(spacing: 4) {
                                            Image(systemName: "checkmark")
                                                .font(.title2)
                                            Text("Accept")
                                                .font(.caption)
                                        }
                                        .foregroundColor(.white)
                                        .frame(width: 60)
                                    } background: { isHighlighted in
                                        ColorPalette.accent(
                                            for: colorScheme
                                        )
                                        .opacity(isHighlighted ? 0.8 : 1)
                                    }
                                    .allowSwipeToTrigger()
                                } trailingActions: { context in
                                    SwipeAction {
                                        Task {
                                            await chatRequestVM
                                                .respondToMeetUpRequest(
                                                    requestId: request.id,
                                                    response: .declined
                                                )
                                        }
                                    } label: { isHighlighted in
                                        VStack(spacing: 4) {
                                            Image(systemName: "xmark.circle")
                                                .font(.title2)
                                            Text("Decline")
                                                .font(.caption)
                                        }
                                        .foregroundColor(.white)
                                        .frame(width: 60)
                                    } background: { isHighlighted in
                                        Color.red
                                            .opacity(
                                                isHighlighted ? 0.8 : 1)
                                    }
                                    .allowSwipeToTrigger()
                                }
                                .swipeOffsetCloseAnimation(
                                    stiffness: 500, damping: 600
                                )
                                .swipeOffsetExpandAnimation(
                                    stiffness: 500, damping: 600
                                )
                                .swipeOffsetTriggerAnimation(
                                    stiffness: 500, damping: 600
                                )
                                .swipeMinimumDistance(20)
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                }
            }
            //            }
            .navigationTitle("Meetup Requests")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(32)
        .sheet(item: $chatRequestVM.selectedRequest) { request in
            MeetUpRequestDetailsView(request: request)
                .presentationDetents([.medium, .large])
        }
        .onChange(of: chatRequestVM.newConversationId) { oldValue, newValue in
            if newValue != nil {
                navigateToChat = true
                dismiss()
            }
        }
        .navigationDestination(isPresented: $navigateToChat) {
            if let conversationId = chatRequestVM.newConversationId,
                let request = chatRequestVM.selectedRequest
            {
                MessageView(
                    conversationId: conversationId,
                    messagerName: userVM.getUserName(
                        from: request.data.senderAccountId)
                )
            }
        }

    }
}

struct MeetUpRequestRow: View {
    var request: ChatRequestDocument
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: 16) {
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
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundColor(
                            ColorPalette.secondaryText(for: colorScheme))
                }
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .foregroundColor(
                        ColorPalette.secondaryText(for: colorScheme))
            }

            // Text Content
            VStack(alignment: .leading, spacing: 8) {
                Text(
                    "From: \(userVM.getUserName(from: request.data.senderAccountId))"
                )
                .font(.title)
                .padding(.top, 4)
                .foregroundColor(ColorPalette.text(for: colorScheme))

                Text(request.data.message)
                    .font(.body)
                    .foregroundColor(
                        ColorPalette.secondaryText(for: colorScheme)
                    )
                    .padding(.top, 5)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)  // Align content to the left
        .background(ColorPalette.main(for: colorScheme))
        .cornerRadius(24)
    }
}

#Preview {
    @Previewable @State var previewDetent: PresentationDetent = .medium

    MeetUpRequestsListView(chatRequestListDetent: $previewDetent)
        .environmentObject(ChatRequestViewModel.mock())
        .environmentObject(UserViewModel.mock())
}
