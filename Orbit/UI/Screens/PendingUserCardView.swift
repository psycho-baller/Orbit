//
//  PendingUserCardView.swift
//  Orbit
//
//  Created by Nathaniel D'Orazio on 2024-11-25.
//
import SwiftUI

struct PendingUserCardView: View {
    let user: UserModel
    let currentUser: UserModel?
    @EnvironmentObject var chatRequestVM: ChatRequestViewModel
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var isHidden = false
    
    var body: some View {
        if !isHidden {
            SwipeView {
                VStack(alignment: .leading, spacing: 8) {
                    // User Name
                    Text(user.name)
                        .font(.title)
                        .padding(.bottom, 1)
                        .foregroundColor(ColorPalette.text(for: colorScheme))

                    // User Interests
                    if let interests = user.interests {
                        InterestsHorizontalTags(
                            interests: interests,
                            onTapInterest: { interest in
                                withAnimation {
                                    userVM.toggleInterest(interest)
                                }
                            }
                        )
                    } else {
                        Text("No interests available")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(ColorPalette.main(for: colorScheme))
                .cornerRadius(32)
            } trailingActions: { _ in
                SwipeAction {
                    cancelRequest()
                } label: { isHighlighted in
                    VStack(spacing: 4) {
                        Image(systemName: "xmark.circle")
                            .font(.title2)
                        Text("Cancel")
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
            .swipeMinimumDistance(20)
        }
    }
    
    private func cancelRequest() {
        // Find the pending request for this user
        if let request = chatRequestVM.requests.first(where: { request in
            request.data.receiverAccountId == user.accountId &&
            request.data.senderAccountId == currentUser?.accountId &&
            request.data.status == .pending
        }) {
            Task {
                await chatRequestVM.respondToMeetUpRequest(
                    requestId: request.id,
                    response: .declined
                )
            }
        }
    }
}
