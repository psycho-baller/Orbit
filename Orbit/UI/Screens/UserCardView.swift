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
                   .frame(maxWidth: .infinity)
                   .background(.ultraThinMaterial)
                   .background(ColorPalette.main(for: colorScheme))
                   .cornerRadius(10)
                   .shadow(radius: 3)
                   .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                       // Right Swipe Action: Send Quick Request
                       if !chatRequestVM.hasSentRequest(to: user.accountId) {
                           Button {
                               sendQuickRequest()
                           } label: {
                               Label("Request", systemImage: "checkmark.circle.fill")
                           }
                           .tint(.green)
                       }
                   }
                   .swipeActions(edge: .leading, allowsFullSwipe: true){
                       // Left Swipe Action: Ignore User
                       Button(role: .destructive) {
                           isHidden = true
                       } label: {
                           Label("Ignore", systemImage: "xmark.circle.fill")
                       }
                       .tint(.red)
                   }
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
        }
    }
}
