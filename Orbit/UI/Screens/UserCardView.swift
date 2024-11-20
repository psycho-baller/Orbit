//
//  UserCardView.swift
//  Orbit
//
//  Created by Nathaniel D'Orazio on 2024-11-18.
//

import Foundation
import SwiftUI

struct UserCardView: View {
    let user: UserModel
    let currentUser: UserModel?
    @EnvironmentObject var chatRequestVM: ChatRequestViewModel
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var offset: CGFloat = 0
    @State private var isSwiped = false
    @State private var isHidden = false

    // Constants for swipe thresholds
    private let rightThreshold: CGFloat = UIScreen.main.bounds.width * 0.5
    private let leftThreshold: CGFloat = UIScreen.main.bounds.width * 0.75

    var body: some View {
        if !isHidden {
            ZStack {
                // Right swipe background (quick request)
                if offset > 0 {
                    ZStack {
                        Color.green
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                            .padding(.leading, 20)
                    }
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                // Left swipe background (hide)
                if offset < 0 {
                    ZStack {
                        Color.red
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                            .padding(.leading, 20)
                    }
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                // User Card Content
                VStack(alignment: .leading, spacing: 8) {
                    Text(user.name)
                        .font(.title)
                        .padding(.bottom, 1)
                        .foregroundColor(ColorPalette.text(for: colorScheme))

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
                            .foregroundColor(Color.gray)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
                .background(ColorPalette.main(for: colorScheme))
                .cornerRadius(10)
                .shadow(radius: 3)
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            // Allow swipe left at any time; only check right swipe conditions
                            if !isSwiped && (gesture.translation.width < 0 || !chatRequestVM.hasSentRequest(to: user.accountId)) {
                                offset = gesture.translation.width
                            }
                        }
                        .onEnded { gesture in
                            // Handle left swipe (always allowed)
                            if offset < -leftThreshold {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.9)) {
                                    offset = -UIScreen.main.bounds.width
                                    isHidden = true
                                }
                                return
                            }

                            // Handle right swipe (only if a request hasn't been sent)
                            if offset > rightThreshold {
                                if !chatRequestVM.hasSentRequest(to: user.accountId) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        isSwiped = true
                                    }
                                    sendQuickRequest()
                                } else {
                                    // Reset position if request was already sent
                                    withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                        offset = 0
                                    }
                                }
                            } else {
                                // Reset position if swipe is not enough
                                withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                    offset = 0
                                }
                            }
                        }
                )
            }
            .frame(maxWidth: .infinity)
            .transition(.opacity)
        }
    }

    private func sendQuickRequest() {
        guard let senderAccountId = currentUser?.accountId else {
            print("Error: Current user is nil.")
            return
        }

        let request = ChatRequestModel(
            senderAccountId: senderAccountId,
            receiverAccountId: user.accountId,
            message: "👋 Hi! Would you like to meet up?"
        )

        Task {
            await chatRequestVM.sendMeetUpRequest(request: request)
            chatRequestVM.markRequestSent(to: user.accountId) // Mark request as sent
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                offset = 0
                isSwiped = false
            }
        }
    }
}
