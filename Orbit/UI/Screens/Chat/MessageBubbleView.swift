//
//  MessageBubbleView.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-03-14.
//

import SwiftUI

struct MessageBubbleView: View {
    let message: ChatMessageDocument
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.colorScheme) var colorScheme

    var isFromCurrentUser: Bool {
        // Assuming `userVM.currentUser?.id` is available
        return message.data.sentByUser?.id == userVM.currentUser?.id
    }

    var body: some View {
        HStack {
            if isFromCurrentUser { Spacer() }
            Text(message.data.content)
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

        ChatDetailView(chat: .mock(), user: .mock())
            .environmentObject(UserViewModel.mock())
            .accentColor(ColorPalette.accent(for: colorScheme))

    }
#endif
