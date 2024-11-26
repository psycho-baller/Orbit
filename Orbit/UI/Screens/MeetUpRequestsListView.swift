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

    var body: some View {
        NavigationView {
            ZStack {
                ColorPalette.lightGray(for: colorScheme)
                    .ignoresSafeArea()
                
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
                                        await chatRequestVM.fetchRequestsForUser(userId: accountId)
                                    }
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(ColorPalette.accent(for: colorScheme))
                            .padding()
                        }
                    } else if chatRequestVM.requests.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "bell.slash")
                                .font(.system(size: 50))
                                .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                            
                            Text("No pending requests")
                                .font(.headline)
                                .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                            
                            Text("When someone sends you a meetup request, it will appear here")
                                .font(.subheadline)
                                .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        ScrollView {
                            VStack(spacing: 24) {
                                ForEach(chatRequestVM.requests) { request in
                                    SwipeView {
                                        MeetUpRequestRow(request: request)
                                            .onTapGesture {
                                                chatRequestVM.selectedRequest = request
                                                chatRequestListDetent = .large
                                            }
                                    } leadingActions: { _ in
                                        SwipeAction {
                                            Task {
                                                await chatRequestVM.respondToMeetUpRequest(
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
                                            ColorPalette.accent(for: colorScheme)
                                                .opacity(isHighlighted ? 0.8 : 1)
                                        }
                                        .allowSwipeToTrigger()
                                    } trailingActions: { _ in
                                        SwipeAction {
                                            Task {
                                                await chatRequestVM.respondToMeetUpRequest(
                                                    requestId: request.id,
                                                    response: .declined
                                                )
                                            }
                                        } label: { isHighlighted in
                                            VStack(spacing: 4) {
                                                Image(systemName: "xmark")
                                                    .font(.title2)
                                                Text("Decline")
                                                    .font(.caption)
                                            }
                                            .foregroundColor(.white)
                                            .frame(width: 60)
                                        } background: { isHighlighted in
                                            Color.red
                                                .opacity(isHighlighted ? 0.8 : 1)
                                        }
                                        .allowSwipeToTrigger()
                                    }
                                    .swipeOffsetCloseAnimation(stiffness: 500, damping: 600)
                                    .swipeOffsetExpandAnimation(stiffness: 500, damping: 600)
                                    .swipeOffsetTriggerAnimation(stiffness: 500, damping: 600)
                                    .swipeMinimumDistance(20)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 24)
                        }
                    }
                }
            }
            .navigationTitle("Meetup Requests")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(32)
        .sheet(item: $chatRequestVM.selectedRequest) { request in
            MeetUpRequestDetailsView(request: request)
                .presentationDetents([.medium, .large])
        }
    }
}

struct MeetUpRequestRow: View {
    var request: ChatRequestDocument
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("From: \(userVM.getUserName(from: request.data.senderAccountId))")
                .font(.title)
                .padding(.bottom, 1)
                .foregroundColor(ColorPalette.text(for: colorScheme))

            Text(request.data.message)
                .font(.body)
                .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
        }
        .frame(maxWidth: .infinity)
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

