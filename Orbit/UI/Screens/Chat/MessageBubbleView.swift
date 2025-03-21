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

    var isFromCurrentUser: Bool {
        // Assuming `userVM.currentUser?.id` is available
        return message.data.sentByUser?.id == userVM.currentUser?.id
    }

    var body: some View {
        HStack {
            if isFromCurrentUser { Spacer() }
            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.data.content)
                    .padding()
                    .background(
                    isFromCurrentUser
                        ? .accentColor
                        : ColorPalette.lightGray(for: colorScheme)
                    )
                    .foregroundColor(isFromCurrentUser ? .white : .black)
                    .cornerRadius(15)

//                Text("Today at \(message.timestamp)") // Example timestamp format
//                    .font(.caption)
//                    .foregroundColor(.gray)
            }
            if !isFromCurrentUser { Spacer() }
        }
        .padding(.horizontal)
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
