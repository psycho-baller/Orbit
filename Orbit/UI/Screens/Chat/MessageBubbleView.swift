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
    @Environment(\.colorScheme) var colorScheme

    var isFromCurrentUser: Bool {
        print(
            "message.sentByUser?.id: \(String(describing: message.sentByUser?.id))"
        )
        print(
            "userVM.currentUser?.id: \(String(describing: userVM.currentUser?.id))"
        )
        // Assuming `userVM.currentUser?.id` is available
        return message.sentByUser?.id == userVM.currentUser?.id
    }

    var body: some View {
        HStack {
            if isFromCurrentUser { Spacer() }
            Text(message.content)
                .padding()
                .background(
                    isFromCurrentUser
                        ? .accentColor
                        : ColorPalette.lightGray(for: colorScheme)
                )
                .foregroundColor(isFromCurrentUser ? .white : .white)
                .cornerRadius(10)
            if !isFromCurrentUser { Spacer() }
        }
        .frame(
            maxWidth: .infinity,
            alignment: isFromCurrentUser ? .trailing : .leading)
    }
}

#if DEBUG
    #Preview {
        @Previewable @Environment(\.colorScheme) var colorScheme

        ChatDetailView(chat: .mock())
            .environmentObject(UserViewModel.mock())
            .accentColor(ColorPalette.accent(for: colorScheme))

    }
#endif
