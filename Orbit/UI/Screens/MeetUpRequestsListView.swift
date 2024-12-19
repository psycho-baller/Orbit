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
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    @Binding var chatRequestListDetent: PresentationDetent
    @Environment(\.dismiss) var dismiss

    private func refreshRequests() {
        guard let userId = userVM.currentUser?.accountId else { return }
        Task {
            await chatRequestVM.fetchRequestsForUser(userId: userId)
        }
    }

    private func approveRequest(request: ChatRequestDocument) async {
        let receiverName = userVM.getUserName(
            from: request.data.receiverAccountId)
        dismiss()
        if let conversation =
            await chatRequestVM
            .respondToMeetUpRequest(
                requestId: request.id,
                receiverName: receiverName,
                response: .approved
            )
        {

            appState.selectedTab = .messages
            appState.messagesNavigationPath.append(
                ConversationDetailModel(
                    id: conversation.id,
                    messagerName: receiverName,
                    lastMessage: "",
                    timestamp: "Today",
                    isRead: false,
                    lastSenderId: request.data.senderAccountId
                )
            )
        }
    }

    private func declineRequest(request: ChatRequestDocument) async {
        let receiverName =
            userVM.getUserName(
                from: request.data
                    .receiverAccountId)
        await chatRequestVM
            .respondToMeetUpRequest(
                requestId: request.id,
                receiverName: receiverName,
                response: .declined
            )
    }

    var body: some View {
        NavigationStack {
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
                } else if chatRequestVM.incomingRequests.filter({
                    $0.data.status == .pending
                }).isEmpty {
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
                            ForEach(
                                chatRequestVM.incomingRequests.filter {
                                    $0.data.status == .pending
                                }
                            ) { request in
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
                                            await approveRequest(
                                                request: request)
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
                                            await declineRequest(
                                                request: request)
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
            .navigationTitle("Meet-up Requests")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                refreshRequests()
            }
        }
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(32)
        .sheet(item: $chatRequestVM.selectedRequest) { request in
            NavigationStack {
                MeetUpRequestDetailsView(
                    request: request,
                    approveRequest: { request in
                        Task {
                            await approveRequest(request: request)
                        }
                    },
                    declineRequest: { request in
                        Task {
                            await declineRequest(request: request)
                        }
                    }
                )
            }
            .presentationDetents([.large])
            .presentationBackground(.ultraThinMaterial)
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
                    "\(userVM.getUserName(from: request.data.senderAccountId))"
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

#if DEBUG
    #Preview {
        @Previewable @State var previewDetent: PresentationDetent = .medium

        MeetUpRequestsListView(chatRequestListDetent: $previewDetent)
            .environmentObject(ChatRequestViewModel.mock())
            .environmentObject(UserViewModel.mock())
    }
#endif
