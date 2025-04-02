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
    private var bubbleColor: Color {
        if isFromCurrentUser {
            // Sent bubble
            return colorScheme == .dark
                ? Color(red: 0.2, green: 0.65, blue: 0.85)  // Darker teal-like color for dark mode
                : .accentColor  // Existing color in light mode
        } else {
            // Received bubble
            return colorScheme == .dark
                ? Color(red: 0.2, green: 0.2, blue: 0.25)  // Subdued dark gray for dark mode
                : ColorPalette.lightGray(for: colorScheme)
        }
    }

    // Dynamic text color based on dark/light mode and ownership
    private var textColor: Color {
        if isFromCurrentUser {
            // Sent messages typically use white text
            return .white
        } else {
            // Received messages: white text in dark mode, black in light mode
            return colorScheme == .dark ? .white : .black
        }
    }

    var body: some View {
        HStack {
            if isFromCurrentUser { Spacer() }
            VStack(
                alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4
            ) {
                Text(message.data.content)
                    .padding()
                    .background(bubbleColor)
                    .foregroundColor(textColor)
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
