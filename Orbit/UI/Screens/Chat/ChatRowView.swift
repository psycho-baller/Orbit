//
//  ChatRowView.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-03-14.
//

import SwiftUI

struct ChatRowView: View {
    let chat: ChatDocument
    let currentUser: UserModel?

    var otherUser: UserModel? {
        chat.data.createdByUser?.id == currentUser?.id
            ? chat.data.otherUser : chat.data.createdByUser
    }

    var lastMessage: String {
        chat.data.messages?.last?.content ?? "No messages yet"
    }

    var meetupTitle: String {
        chat.data.meetupRequest?.title ?? "Unknown Meetup"
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(otherUser?.username ?? "Unknown User")
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(meetupTitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                Text(lastMessage)
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
}
