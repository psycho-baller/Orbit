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
                //            .frame(maxWidth: .infinity)
                //            .background(.ultraThinMaterial)
                .background(ColorPalette.main(for: colorScheme))
                //            .cornerRadius(10)
                //            .shadow(radius: 3)
            } leadingActions: { _ in
                SwipeAction("Request") {
                    sendQuickRequest()
                }.allowSwipeToTrigger()
            } trailingActions: { _ in
                SwipeAction("Ignore") {
                    isHidden = true
                }.allowSwipeToTrigger()
            }
            .swipeOffsetCloseAnimation(stiffness: 500, damping: 600)
            .swipeOffsetExpandAnimation(stiffness: 500, damping: 600)
            .swipeOffsetTriggerAnimation(stiffness: 500, damping: 600)
            .swipeMinimumDistance(20)
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
<<<<<<< HEAD
            await chatRequestVM.sendMeetUpRequest(request: request)
=======
            await chatRequestVM.sendMeetUpRequest(
                request: request, from: currentUser?.name)
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
            chatRequestVM.markRequestSent(to: user.accountId)  // Mark request as sent
        }
    }
}
