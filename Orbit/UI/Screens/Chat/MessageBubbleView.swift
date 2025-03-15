//
//  MessageBubbleView.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-03-14.
//

import SwiftUI

struct MessageBubbleView: View {
    let message: ChatMessageModel
    @EnvironmentObject var userVM: UserViewModel

    var isFromCurrentUser: Bool {
        // Assuming `userVM.currentUser?.id` is available
        message.sentByUser.id == userVM.currentUser?.id
    }

    var body: some View {
        HStack {
            if isFromCurrentUser { Spacer() }
            Text(message.content)
                .padding()
                .background(
                    isFromCurrentUser ? Color.blue : Color.gray.opacity(0.2)
                )
                .foregroundColor(isFromCurrentUser ? .white : .black)
                .cornerRadius(10)
            if !isFromCurrentUser { Spacer() }
        }
        .frame(
            maxWidth: .infinity,
            alignment: isFromCurrentUser ? .trailing : .leading)
    }
}
